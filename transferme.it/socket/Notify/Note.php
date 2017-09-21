<?php
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

error_reporting(E_ALL);
ini_set("display_errors", 1);

require '/var/www/transferme.it/public_html/app/functions.php';

function jsonTime($time){
    return json_encode(array("type" => "time", "time" => $time));
}

function jsonError($error_message){
    return json_encode(array("type" => "error", "message" => $error_message));
}

//initial set all users as not connected
mysqli_query(connect(), "
UPDATE `user`
SET connected = 0
");

class Note implements MessageComponentInterface {
    public $clients;
	protected $UUID;
	protected $activity;

    public function __construct() {
        $this->clients = new \SplObjectStorage;
    }

    public function onOpen(ConnectionInterface $conn) {
		$connection_ip = $conn->WebSocket->request->getHeader('X-Real-IP');

        if (!filter_var($connection_ip, FILTER_VALIDATE_IP) === false) {
            //check if user has been active in last 5 seconds
            $time_since = mysqli_query(connect(), "SELECT id
            FROM `IPs`
            WHERE ip = '$connection_ip'
            AND last_access >= now() - interval 5 second");

            if (mysqli_num_rows($time_since) > 0) {
                customLog("New socket");
                $this->clients->attach($conn);
            } else {
                customLog("Fishy connection from: $connection_ip");
                $conn->send(jsonError("fishy connection"));
                $conn->close();
            }
        }else{
            customLog("Suspicious ip header: $connection_ip");
        }
    }

    public function onMessage(ConnectionInterface $from, $input) {
		$con = connect();

        $json = json_decode($input);

        if(json_last_error() != JSON_ERROR_NONE){
            $from->close();
        }else {
            $type = $json->type;
            if ($type === "time") {
                //ASKING FOR TIME LEFT OF USER CODE
                $user = mysqli_real_escape_string($con, $json->userCode);
                $UUID = mysqli_real_escape_string($con, $json->UUID);
                foreach ($this->clients as $client) {
                    if ($from === $client) {
                        // asking about UUID from socket linked with uuid
                        if (isset($client->UUID) && $client->UUID == myHash($UUID)) {
                            $client->activity = date("Y-m-d H:i:s");
                            $hashedUUID = userToHashedUUID($con, $user);
                            if ($hashedUUID != null) {
                                $time_left = getUserTimeLeft($con, $hashedUUID);
                                $from->send(jsonTime($time_left));
                            } else {
                                $from->send(jsonTime("-"));
                            }
                        }
                    }
                }
            } else if ($type === "keep") {
                // USER IS STILL UPLOADING OR DOWNLOADING - tells server to postpone deleting the file.
                $user = mysqli_real_escape_string($con, $json->userCode);
                $UUID = mysqli_real_escape_string($con, $json->UUID);
                $path = mysqli_real_escape_string($con, $json->path);

                foreach ($this->clients as $client) {
                    if ($from === $client) {
                        // asking about UUID from socket linked with UUID
                        if (isset($client->UUID) && $client->UUID == myHash($UUID)) {
                            $hashedUUID = userToHashedUUID($con, $user);
                            if ($hashedUUID != null) {
                                updateUploadTime($con, $hashedUUID, $path);
                            }
                        }
                    }
                }
            }else if ($type == "connect") {
                // initial socket connection
                $UUID = mysqli_real_escape_string($con, $json->UUID);
                $UUIDKey = mysqli_real_escape_string($con, $json->key);

                if(!validUUID($UUID)){
                    $from->close();
                }

                if (isConnected($con, myHash($UUID))) {
                    $from->send(jsonError("User already connected to socket"));
                    $from->close();
                } else {
                    if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
                        customLog("Invalid key match -> ".myHash($UUID)." with key: ".myHash($UUIDKey));
                        $from->send(jsonError("Invalid key. You have likely altered Keychain"));
                        $from->close();
                    } else {
                        foreach ($this->clients as $client) {
                            if ($from === $client) {
                                //return time left
                                $time_left = getUserTimeLeft($con, myHash($UUID));
                                if ($time_left == "-") {
                                    $from->send(jsonTime("-"));
                                    $from->close();
                                } else {
                                    markUserSocketConnection($con, myHash($UUID), TRUE);
                                    $client->UUID = myHash($UUID);
                                    $client->activity = date("Y-m-d H:i:s");
                                    $from->send(jsonTime($time_left));
                                    customLog("New client: " . $client->UUID);
                                }
                            }
                        }
                    }
                }
            }else{
                $from->close();
            }
        }
    }

	public function onLocal($input)
	{
	    $arr = json_decode($input);
        if(json_last_error() != JSON_ERROR_NONE){
            customLog("Error with json sent to onLocal: $input");
        }else{
            $to = $arr->to;
            $message = $arr->message;

            if ($message == "close") {
                //user has expired force close socket user socket
                foreach ($this->clients as $client) {
                    if (isset($client->UUID) && $to == $client->UUID) {
                        $client->send(jsonTime("-")); //in turn will tell user to create a new user
                        $client->close();
                        break;
                    }
                }
            } else {
                //forward socket message to client
                foreach ($this->clients as $client) {
                    if (isset($client->UUID) && $to == $client->UUID) {
                        $client->send($message);
                        break;
                    }
                }
            }
        }
	}

    public function onClose(ConnectionInterface $conn) {
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				if(isset($client->UUID)) {
					customLog("connection closed " . $client->UUID);
					markUserSocketConnection(connect(), $client->UUID, FALSE);
					//remove client code
					$client->UUID = NULL;
				}
			}
		}
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e) {
		customLog("connection error:");
        $conn->send(print_r($e));
        $conn->close();
    }
}