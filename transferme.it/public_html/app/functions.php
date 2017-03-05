***REMOVED***
$upload_dir = $_SERVER["DOCUMENT_ROOT"].'/uploads/';
$custom_pro_mb = 5000;
$free_user_bandwidth = megaToBytes(2500);
$amt_max_files = 5;
$default_max_file_upload = megaToBytes(200);
$default_max_mins = 10;

//database stuff
function connect(){
	$config = parse_ini_file('/var/www/transferme.it/db.ini');
	$con = mysqli_connect("localhost", $config['username'], $config['password'], $config['db']);
	if(!$con){
		die("Failed to connect to Database"); 
	***REMOVED***
	return $con;
***REMOVED***

function UUIDRegistered($con, $UUID){
	if(validUUID($UUID)){
		$uuidExists = mysqli_query($con, "
		SELECT * 
		FROM `user`
		WHERE UUID = '".myHash($UUID)."'
		");
 
		if(mysqli_num_rows($uuidExists) > 0){
			return true;
		***REMOVED***
	***REMOVED***
	return false;
***REMOVED***

function correctUUIDKey($con, $UUID, $key){
	if (UUIDRegistered($con, $UUID)) {
		$fetchKey = mysqli_query($con, "
		SELECT * 
		FROM `user`
		WHERE UUID = '".myHash($UUID)."'
		LIMIT 1
		");

		if (mysqli_num_rows($fetchKey) > 0) {
			while ($row = mysqli_fetch_array($fetchKey)) {
				if(myHash($key) == $row['UUIDKey']) return true;
			***REMOVED***
		***REMOVED***
	***REMOVED***
	return false;
***REMOVED***

/* converts user code to UUID will return null if no such user */
function userToHashedUUID($con, $user){
	$getUUID = mysqli_query($con, "SELECT UUID, connected
	FROM `user`
	WHERE `user` = '".myHash($user)."'
	LIMIT 1");

	if(mysqli_num_rows($getUUID) > 0) {
		while ($row = mysqli_fetch_array($getUUID)) {
			$hashedUUID = $row['UUID'];
			if($row['connected'] == 1 && getUserTimeLeft($con, $hashedUUID) != "00:00"){
				return $hashedUUID;
			***REMOVED***else{
				sendLocalSocket("close|$hashedUUID");
			***REMOVED***
		***REMOVED***
	***REMOVED***

	return null;
***REMOVED***

/* gets time left before code expires */
function getUserTimeLeft($con, $hashedUUID){
	global $default_max_mins;
	$query = mysqli_query($con, "
	SELECT created, wantedMins
	FROM `user`
	WHERE UUID = '$hashedUUID'
	");

	$wantedMins = $default_max_mins;
	while ($row = mysqli_fetch_array($query)){
		$wantedMins = $row['wantedMins'];
		$timeStarted = $row['created'];
	***REMOVED***

	if(!empty($timeStarted)) {
		$endTime = date("Y-m-d H:i:s", strtotime($timeStarted . " +" . $wantedMins . " minutes"));
		$now = date("Y-m-d H:i:s");

		if (new DateTime($now) <= new DateTime($endTime)) {
			$timeLeft = strtotime($endTime) - strtotime($now);
			//get hours
			$hours = date("H", $timeLeft);
			//get mins
			$mins = date("i", $timeLeft);
			if($hours > 0){
				$mins += $hours * 60;
			***REMOVED***
			//get seconds
			$secs = date("s", $timeLeft);

			return "$mins:$secs";
		***REMOVED***
	***REMOVED***

	//EXPIRED
	//delete user
	deleteUser($con, $hashedUUID);
	return "00:00";
***REMOVED***

/* deletes user code from database (does not delete rollollopp9 */
function deleteUser($con, $hashedUUID){
	mysqli_query($con, "
	UPDATE `user`
	SET user = NULL, connected = 0
	WHERE UUID = '$hashedUUID'
	");
	
	//close socket
	sendLocalSocket("close|$hashedUUID");
***REMOVED***

/* mark user as connected to server or not */
function markUserSocketConnection($con, $hashedUUID, $isConnected){
	return mysqli_query($con, "
	UPDATE `user`
	SET connected = ". intval($isConnected) ."
	WHERE UUID = '$hashedUUID'
	");
***REMOVED***

/* return whether the user is connected to the server or not */
function isConnected($con, $hashedUUID){
	$isConnectedQuery = mysqli_query($con, "
	SELECT connected
	FROM `user`
	WHERE UUID = '$hashedUUID'
	");
	
	while ($row = mysqli_fetch_array($isConnectedQuery)){
		if($row['connected'] == 1){
			return true;
		***REMOVED***
	***REMOVED***

	return false;
***REMOVED***
 
// input checks
function validUUID($UUID){
	return preg_match('/^\{?[A-Z0-9]{8***REMOVED***-[A-Z0-9]{4***REMOVED***-[A-Z0-9]{4***REMOVED***-[A-Z0-9]{4***REMOVED***-[A-Z0-9]{12***REMOVED***\***REMOVED***?$/', $UUID);
***REMOVED***

function hasSpecialChars($string){
	return preg_match('/[^A-Za-z0-9]/', $string);
***REMOVED***

// Returns true if one of the predefined allowed minutes the user code can exist for.
function allowedMins($min){
	return in_array($min, array(5, 10, 15, 20, 30, 45, 60));
***REMOVED***

// 36^7 = 78,364,164,096 possible users
function genUser(){
	return strtoupper(generateRandomString(7));
***REMOVED***

// Returns true if the user code is 7 chars long and consists of only capitals and numbers
function validUserFormat($user){
	if(strlen($user) != 7){
		return false;
	***REMOVED***

	if (preg_match('/[^A-Z0-9]/', $user)) //string doesn't contain only caps and numbers
	{
		return false;
	***REMOVED***

	return true;
***REMOVED***

function getPermUserCode($con, $UUID, $perm_user){

	$query = mysqli_query($con, "SELECT perm_user, perm_user_expiry 
	FROM `pro`
	WHERE UUID = '".myHash($UUID)."'
	AND perm_user = '".myHash($perm_user)."'
	");

	if(mysqli_num_rows($query) > 0){
		return true;
	***REMOVED***
	return false;
***REMOVED***

function getCredit($con, $hashedUUID){
	$get_credit = mysqli_query($con,"SELECT SUM(credit) as total_credit
	FROM `pro`
	WHERE UUID = '$hashedUUID'");

	while ($row = mysqli_fetch_array($get_credit)) {
		return $row['total_credit'];
	***REMOVED***
	return 0;
***REMOVED***

//!important algorithm to calculate the total bandwidth a user should get based on credit.
function creditToMaxUpload($credit){
	if($credit > 0) return $credit * 1000;
	return 0;
***REMOVED***
function creditToBandwidth($credit){
	global $free_user_bandwidth, $amt_max_files;
	
	$tmp_credit = 0;
	$bandwidth = $free_user_bandwidth;
	while ($credit >= $tmp_credit){
		$bandwidth += megaToBytes(creditToMaxUpload($tmp_credit)) * $amt_max_files;
		$tmp_credit += 0.5;
	***REMOVED***
	return $bandwidth;
***REMOVED***

function bandwidthToCredit($bandwidth){
	global $free_user_bandwidth, $amt_max_files;

	$credit = 0;
	$tmp_bandwidth = $free_user_bandwidth;
	while($bandwidth > $tmp_bandwidth){
		$credit += 0.5;
		$tmp_bandwidth += megaToBytes(creditToMaxUpload($credit)) * $amt_max_files;
	***REMOVED***
	
	return $credit;
***REMOVED***

//returns the amount of bytes the user has used
function getUsedBandwidth($con, $hashedUUID, $free_user = false){
	$addSQL = "";
	if($free_user){
		// only find bandwidth used today
		// and where bandwidth wasn't used when pro
		$addSQL = "AND DATE(`finished`) = CURDATE()
				   AND `pro` = 0";
	***REMOVED***
	$get_bandwidth = mysqli_query($con,"SELECT SUM(size) as used_bandwidth
	FROM `upload`
	WHERE fromUUID = '$hashedUUID' $addSQL");
	while ($row = mysqli_fetch_array($get_bandwidth)) {
		return $row['used_bandwidth'];
	***REMOVED***
	return 0;
***REMOVED***

function getBandwidthLeft($con, $hashedUUID){
	global $free_user_bandwidth;

	$user_credit = getCredit($con, $hashedUUID);
	$total_bandwidth = creditToBandwidth($user_credit);
	$used_bandwidth = getUsedBandwidth($con, $hashedUUID);

	$bandwidth_left = $total_bandwidth - $used_bandwidth;

	if($bandwidth_left <= $free_user_bandwidth) {
		//free user - limited to today
		$bandwidth_used_today = getUsedBandwidth($con, $hashedUUID, true);
		$bandwidth_left = $free_user_bandwidth - $bandwidth_used_today;
	***REMOVED***

	if($bandwidth_left < 0) return 0; //prevents negative bandwidth left. (should be impossible)
	
	return $bandwidth_left;
***REMOVED***

function maxUploadSize($bandwidth_left){
	global $free_user_bandwidth, $default_max_file_upload;

	if ($bandwidth_left > $free_user_bandwidth) {
		$rounded_credit = ceil(bandwidthToCredit($bandwidth_left) * 2) / 2; //rounds up 0.5
		return megaToBytes(creditToMaxUpload($rounded_credit));
	***REMOVED***else if($bandwidth_left > $default_max_file_upload){
		//free user
		return $default_max_file_upload;
	***REMOVED***

	return $bandwidth_left;
***REMOVED***

function getMaxUploadSize($con, $hashedUUID){
	$bandwidth_left = getBandwidthLeft($con, $hashedUUID);
	return maxUploadSize($bandwidth_left);
***REMOVED***

// Updates the `updated` time in the `upload` database.
// This is so that the file is not deleted if a user is still deleting or uploading the file.
function updateUploadTime($con, $aUUID, $path){
	customLog("update upload time: $aUUID to $path", TRUE);
	
    $query = mysqli_query($con, "UPDATE `upload`
    SET updated = NOW()
    WHERE fromUUID = '$aUUID'
    OR toUUID = '$aUUID'
    AND path='$path'");
    
    if($query){
        return true;
    ***REMOVED***else{
        return false;
    ***REMOVED***
***REMOVED***

// Removes unimportant information on the upload and
// the actual directory of where the file was located using "Secure Remove"
function deleteUpload($con, $toUUID, $fromUUID, $path, $failed = FALSE){
	if(strlen(trim($path)) > 0) {
		$query = mysqli_query($con, "UPDATE `upload`
		SET toUUID = NULL, path = NULL, finished = NOW(), partialKey = NULL, hash = NULL, failed = '".(int)$failed."'
		WHERE fromUUID = '$fromUUID'
		AND toUUID = '$toUUID'
		AND path = '$path'
		");

		if ($query) {
			//delete folder using srm
			$dir = getDirPath($path);
			if (deleteDir($dir)) {
				return true;
			***REMOVED***
		***REMOVED***
	***REMOVED***
    return false;
***REMOVED***

//returns the id of the row in the `upload` database
//also authenticates variables
function getUploadID($con, $fromUUID, $toUUID){
	//pick newest id
    $upload_id_query = mysqli_query($con, "
    SELECT id
    FROM `upload`
	WHERE fromUUID = '$fromUUID'
	AND toUUID = '$toUUID'
	ORDER BY id DESC
    ");

    while ($row = mysqli_fetch_array($upload_id_query)){
        return $row['id'];
    ***REMOVED***
    return null;
***REMOVED***

//adds the full path to the directory of the path stored in the database
function getDirPath($path){
	global $upload_dir;
	return $upload_dir.$path.'/';
***REMOVED***

//returns the path stored in the database.
function removeDirPath($path){
	global $upload_dir;
	return strtok(str_replace($upload_dir, "", $path),"/");
***REMOVED***

//Deletes a directory with "Secure Delete"
function deleteDir($dir){
	$command = "sudo /var/www/transferme.it/public_html/app/secureDeleteFolder.sh '$dir'";
	$shell = trim(shell_exec($command));
	customLog("deleteDir shell: $shell", TRUE);
	if($shell == "1"){
		return true;
	***REMOVED***
	return false;
***REMOVED***

function sendLocalSocket($message){
	$context = new ZMQContext();
	$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
	$socket->connect("tcp://localhost:47802");
	$socket->send($message);
***REMOVED***

//functions
function generateRandomString($length) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = ''; 
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    ***REMOVED***
    return $randomString;
***REMOVED***

function customLog($message, $silent=false, $file = '/var/www/transferme.it/log/server.log'){
	$message = date("Y-m-d H:i:s")."\t $message\n";

	//output log
	if(!$silent)
		echo $message;

	//store log
	file_put_contents($file, $message.PHP_EOL , FILE_APPEND | LOCK_EX);
***REMOVED***

//ip database
function addIP($con){
	$ip = $_SERVER['REMOTE_ADDR'];
	return mysqli_query($con,"INSERT INTO 
	`IPs` (ip) VALUES ('$ip')
  	ON DUPLICATE KEY UPDATE last_access = NOW();");
***REMOVED***

function megaToBytes($bytes){
	return $bytes * 1048576;
***REMOVED***

function bytesToMega($bytes){
	return $bytes / 1048576;
***REMOVED***

function encryptedFileSize($bytes){
	$overhead = 66;

	if ($bytes == 0) {
		return 16 + $overhead;
	***REMOVED***

	$remainder = $bytes % 16;
	if ($remainder == 0) {
		return $bytes + 16 + $overhead;
	***REMOVED***

	return $bytes + 16 - $remainder + $overhead;
***REMOVED***

function myHash($str){
    return hash("sha256",$str);
***REMOVED***

***REMOVED***