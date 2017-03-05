***REMOVED***
namespace Notify;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
 
***REMOVED***
***REMOVED***

require '/var/www/transferme.it/public_html/app/functions.php';

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
    ***REMOVED***

    public function onOpen(ConnectionInterface $conn) {
		$connection_ip = $conn->WebSocket->request->getHeader('X-Real-IP');

		//check if user has been active in last 20 seconds
		$time_since = mysqli_query(connect(),"SELECT id
		FROM `IPs`
		WHERE ip = '$connection_ip'
		AND last_access >= now() - interval 5 second");

		if(mysqli_num_rows($time_since) > 0) {
			customLog("New socket");
			$this->clients->attach($conn);
		***REMOVED***else{
			customLog("Fishy connection from: $connection_ip");
			$conn->send("fishy connection");
			$conn->close();
		***REMOVED***
    ***REMOVED***

    public function onMessage(ConnectionInterface $from, $message) {
		$con = connect();
		
		$arr = explode("|", $message);
		$message_type = $arr[0];
		
		if ($message_type === "time") {
			//ASKING FOR TIME LEFT OF USER CODE
            $user 	= mysqli_real_escape_string($con, $arr[1]);
			$UUID 	= mysqli_real_escape_string($con, $arr[2]);

			foreach ($this->clients as $client) {
				if ($from === $client) {
					// asking about UUID from socket linked with uuid
					if(isset($client->UUID) && $client->UUID == myHash($UUID)) {
						$client->activity = date("Y-m-d H:i:s");
						$hashedUUID = userToHashedUUID($con, $user);
						if($hashedUUID != null) {
							$time_left = getUserTimeLeft($con, $hashedUUID);
							$from->send("time|$time_left");
						***REMOVED***else{
							$from->send("time|00:00");
						***REMOVED***
					***REMOVED***
				***REMOVED***
			***REMOVED***
		***REMOVED***else if($message_type === "keep") {
			// USER IS STILL UPLOADING OR DOWNLOADING - tells server to postpone deleting the file.
			$UUID 	= mysqli_real_escape_string($con, $arr[1]);
			$user 	= mysqli_real_escape_string($con, $arr[2]);
			$path	= mysqli_real_escape_string($con, $arr[3]);
			
			foreach ($this->clients as $client) {
				if ($from === $client) {
					// asking about UUID from socket linked with UUID
					if (isset($client->UUID) && $client->UUID == myHash($UUID)) {
						$hashedUUID = userToHashedUUID($con, $user);
						if ($hashedUUID != null) {
							updateUploadTime($con, $hashedUUID, $path);
						***REMOVED***
					***REMOVED***
				***REMOVED***
			***REMOVED***
		***REMOVED***else if(validUUID($message_type)){
			// first socket connection
			$UUID 	= mysqli_real_escape_string($con, $message_type);
			$key 	= mysqli_real_escape_string($con, $arr[1]);

			if(isConnected($con, myHash($UUID))){
				$from->send("User already connected to socket");
				$from->close();
			***REMOVED*** else {
				if (!correctUUIDKey($con, $UUID, $key)) {
                    customLog("Invalid Key: $UUID with key: $key");
					$from->send("Invalid key. You have likely altered Keychain");
					$from->close();
				***REMOVED*** else {
					foreach ($this->clients as $client) {
						if ($from === $client) {
							//return time left
							$time_left = getUserTimeLeft($con, myHash($UUID));
							if ($time_left == "00:00") {
								$from->send("time|$time_left");
								$from->close();
							***REMOVED*** else {
								markUserSocketConnection($con, myHash($UUID), TRUE);
								$client->UUID = myHash($UUID);
								$client->activity = date("Y-m-d H:i:s");
								$from->send("time|$time_left");
								customLog("New client: " . $client->UUID);
							***REMOVED***
						***REMOVED***
					***REMOVED***
				***REMOVED***
			***REMOVED***
		***REMOVED***
    ***REMOVED***
	
	public function onLocal($message)
	{
		$con = connect();
		$arr = explode("|", $message);
		$hashedUUID = mysqli_real_escape_string($con, $arr[1]);

		if ($arr[0] == "close") {
			//user has expired force close socket user socket
			foreach ($this->clients as $client) {
				if(isset($client->UUID) && $hashedUUID == $client->UUID){
					$client->send("time|00:00");
					$client->close();
					break;
				***REMOVED***
			***REMOVED*** 
		***REMOVED***else{
			//forward socket message to client

			//remove hashed UUID from message as irrelevant to client
			$message = str_replace("$hashedUUID|", "", $message);

			foreach ($this->clients as $client) {
				if (isset($client->UUID) && $hashedUUID == $client->UUID) {
					$client->send($message);
					break;
				***REMOVED***
			***REMOVED***
		***REMOVED***
	***REMOVED***

    public function onClose(ConnectionInterface $conn) {
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				if(isset($client->UUID)) {
					customLog("connection closed " . $client->UUID);
					markUserSocketConnection(connect(), $client->UUID, FALSE);
					//remove client code
					$client->UUID = NULL;
				***REMOVED***
			***REMOVED***
		***REMOVED***
        $this->clients->detach($conn);
    ***REMOVED***

    public function onError(ConnectionInterface $conn, \Exception $e) {
		customLog("connection error:");
		customLog(print_r($e));
        $conn->close();
    ***REMOVED***
***REMOVED***