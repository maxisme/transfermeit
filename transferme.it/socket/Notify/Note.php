<?php

namespace Notify;

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;


require '/var/www/transferme.it/public_html/app/functions.php';

function jsonTime($time)
{
    return json_encode(array("type" => "time", "time" => $time));
}

function jsonError($error_message)
{
    return json_encode(array("type" => "error", "message" => $error_message));
}

//initial set all users as not connected
mysqli_query(connect(), "
UPDATE `user`
SET connected = 0
");

class Note implements MessageComponentInterface
{
    public $clients;
    protected $UUID;
    protected $serverCode;
    protected $activity;

    public function __construct()
    {
        $this->clients = new \SplObjectStorage;
        $this->serverCode = file_get_contents("/var/www/transferme.it/secret_server_code.pass");
    }

    public function onOpen(ConnectionInterface $conn)
    {
        $connection_ip = $conn->WebSocket->request->getHeader('X-Real-IP');

        if (!filter_var($connection_ip, FILTER_VALIDATE_IP) === false) {
//            //check if user has been active in last 5 seconds
//            $time_since = mysqli_query(connect(), "SELECT id
//            FROM `IPs`
//            WHERE ip = '$connection_ip'
//            AND last_access >= now() - interval 5 second");
//
//            if (mysqli_num_rows($time_since) > 0) {
//                customLog("New socket");
//                $this->clients->attach($conn);
//            } else {
//                customLog("Fishy connection from: $connection_ip");
//                $conn->send(jsonTime("-")); // ask user to create new account
//                $conn->close();
//            }
            customLog("New socket $connection_ip");
            $this->clients->attach($conn);
        } else {
            customLog("Suspicious ip header: $connection_ip");
        }
    }

    public function onMessage(ConnectionInterface $from, $input)
    {
        $con = connect();

        $json = json_decode($input);
        if (json_last_error() != JSON_ERROR_NONE) {
            // input is not json
            $from->close();
        } else {
            $type = $json->type;
            $UUID = san($con, $json->UUID);

            if ($type === "time") {
                //ASKING FOR TIME LEFT OF USER CODE
                $user = san($con, $json->userCode);

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
                                $from->close();
                            }
                        }

                        break; // only ever one matching client
                    }
                }
            } else if ($type === "bw") { // asking for the amount of bandwidth left
                //ASKING FOR TIME LEFT OF USER CODE
                $hashedUUID = myHash($UUID);

                foreach ($this->clients as $client) {
                    if ($from === $client) {
                        // asking about UUID from socket linked with uuid
                        if (isset($client->UUID) && $client->UUID == $hashedUUID) {
                            customLog("1");
                            $bw_left = getBandwidthLeft($con, $hashedUUID);
                            customLog("2");
                            $max_fs = getMaxUploadSize($bw_left);
                            customLog("3");
                            $from->send(json_encode(array(
                                "type" => "bw",
                                "bw_left" => $bw_left,
                                "max_fs" => $max_fs
                            )));
                        }

                        break;
                    }
                }
            } else if ($type === "keep") {
                // USER IS STILL DOWNLOADING - tells server to postpone deleting the file.
                $user = san($con, $json->userCode);
                $path = san($con, $json->path);

                foreach ($this->clients as $client) {
                    if ($from === $client) {
                        // asking about UUID from socket linked with UUID
                        if (isset($client->UUID) && $client->UUID == myHash($UUID)) {
                            $hashedUUID = userToHashedUUID($con, $user);
                            if ($hashedUUID != null) updateUploadTime($con, $hashedUUID, $path);
                        }
                        break;
                    }
                }
            } else if ($type == "connect") {
                // initial socket connection checks whether key is legit
                $UUIDKey = san($con, $json->UUIDKey);

                if ($json->serverKey != $this->serverCode) {
                    $from->close();
                }

                if (!validUUID($UUID)) $from->close();

                if (isConnected($con, myHash($UUID))) {
                    // TODO: better way to handle this case such as a ping.
                    $from->send(jsonError("User already connected to socket. Please wait a few seconds."));
                    $from->close();
                } else {
                    if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
                        customLog("Invalid key match -> " . myHash($UUID) . " with key: " . $UUIDKey);
                        customLog(strlen($UUIDKey));
                        $from->send(jsonError("Invalid UUID and Key match. Please contact max@max.me.uk"));
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

                                break;
                            }
                        }
                    }
                }
            } else {
                // not an acceptable request
                // but not going to tell a hacker that - oh wait this is open source...
                $from->close();
            }
        }
        mysqli_close($con);
    }

    public function onLocal($input)
    {
        $arr = json_decode($input);
        if (json_last_error() != JSON_ERROR_NONE) {
            customLog("Error with json sent to onLocal: $input");
        } else {
            $to = $arr->to;
            $message = $arr->message;

            if ($message == "close") {
                //user has expired force close socket user socket
                foreach ($this->clients as $client) {
                    if (isset($client->UUID) && $to == $client->UUID) {
                        $client->send(jsonTime("-")); //results in forcing a new user to be created
                        $client->close();
                        break;
                    }
                }
            } else {
                //forward socket message to client
                foreach ($this->clients as $client) {
                    if (isset($client->UUID) && $to == $client->UUID) {
                        $client->send(strval($message)); // strval to prevent code injection
                        break;
                    }
                }
            }
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        foreach ($this->clients as $client) {
            if ($conn == $client) {
                if (isset($client->UUID)) {
                    customLog("connection closed " . $client->UUID);
                    markUserSocketConnection(connect(), $client->UUID, FALSE);
                    //remove client code
                    $client->UUID = NULL;
                }
            }
        }
        $this->clients->detach($conn);
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        customLog("connection error:");
        $conn->send(print_r($e));
        $conn->close();
    }
}