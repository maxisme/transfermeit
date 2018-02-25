<?php
$upload_dir = '/var/www/transferme.it/uploads/';
$log_path = "/var/www/transferme.it/log/";

global $daily_allowed_free_user_bandwidth;
$daily_allowed_free_user_bandwidth = megaToBytes(2500);
global $file_upload_size_to_bandwidth_constant;
$file_upload_size_to_bandwidth_constant = 5;
global $default_max_file_upload;
$default_max_file_upload = megaToBytes(200);

$default_max_mins = 10;
$key_len = 100;
$max_allowed_mins = $default_max_mins;
$brute_seconds = 5;
$pro_code_len = 100;

//£ user has of credit
$perm_user_credit_min = 5;
$custom_user_credit_min = 10;

//0 - no credit user
//1 - has credit user
//2 - perm code user
//3 - custom code user
$profile_explanation = array(
    0 => "Free user",
    1 => "Paid user",
    2 => "Permanent code user",
    3 => "Custom code user"
);

function connect(){
	$config = parse_ini_file('/var/www/transferme.it/db.ini');
	$con = mysqli_connect("127.0.0.1", $config['username'], $config['password'], $config['db']);
	if(!$con){
		die("Failed to connect to Database");
	}
	return $con;
}

// used to validate a client
function UUIDRegistered($con, $UUID, $UUIDKey){
    if (validUUID($UUID)) {
        $uuidExists = mysqli_query($con, "
        SELECT * 
        FROM `user`
        WHERE UUID = '" . myHash($UUID) . "'
        AND UUIDKey = '" . myHash($UUIDKey) . "'
        ");

        if (mysqli_num_rows($uuidExists) > 0) return true;
    }
	return false;
}

/*  returns a permenant user code of a UUID if exists
    if $permCode does not match what is expected system will die as this is very dodgy.
*/
function getUserPermCode($con, $UUID, $permCode){
    $pro_user_info = mysqli_query($con, "
    SELECT permUserCode
    FROM `pro`
    WHERE UUID = '" . myHash($UUID) . "'
    ORDER BY created ASC
    LIMIT 1
    "); // pick oldest first as that will always contain the perm code if set

    if (mysqli_num_rows($pro_user_info) > 0) {
        while ($row = mysqli_fetch_array($pro_user_info)) {
            if (isset($row['permUserCode'])) {
                if($permCode){
                    if (myHash($permCode) == $row['permUserCode']) {
                        return $permCode;
                    }
                }
            }
        }
    }
    return false;
}

/* converts user code to UUID will return null if no such user */
function userToHashedUUID($con, $user){
	$getUUID = mysqli_query($con, "SELECT UUID, connected
	FROM `user`
	WHERE `user` = '".myHash($user)."'");

	if(mysqli_num_rows($getUUID) > 0) {
		while ($row = mysqli_fetch_array($getUUID)) {
			$hashedUUID = $row['UUID'];
			if($row['connected'] == 1 && getUserTimeLeft($con, $hashedUUID) != "-"){
				return $hashedUUID;
			}else{
				sendLocalSocket($hashedUUID, "close");
			}
		}
	}

	return null;
}

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
	}

	if(!empty($timeStarted)) {
		$endTime = date("Y-m-d H:i:s", strtotime($timeStarted . " +" . $wantedMins . " minutes"));
		$now = date("Y-m-d H:i:s");

		if (new DateTime($now) <= new DateTime($endTime)) {
			$timeLeft = strtotime($endTime) - strtotime($now);

			//get mins
			$mins = date("i", $timeLeft);

			//get seconds
			$secs = date("s", $timeLeft);

			return "$mins:$secs";
		}
	}

	//EXPIRED
	//delete user
	deleteUser($con, $hashedUUID);
	return "-";
}

/* deletes user code from database */
function deleteUser($con, $hashedUUID){
	mysqli_query($con, "
	UPDATE `user`
	SET user = NULL, connected = 0
	WHERE UUID = '$hashedUUID'
	");

	//close socket
	sendLocalSocket($hashedUUID, "close");
}

/* mark user as connected to server or not */
function markUserSocketConnection($con, $hashedUUID, $isConnected){
	return mysqli_query($con, "
	UPDATE `user`
	SET connected = ". intval($isConnected) ."
	WHERE UUID = '$hashedUUID'
	");
}

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
		}
	}

	return false;
}

// input checks
function validUUID($UUID){
	return preg_match('/^\{?[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}\}?$/', $UUID);
}

function hasSpecialChars($string){
	return preg_match('/[^A-Za-z0-9]/', $string);
}

// Returns true if one of the predefined allowed minutes the user code can exist for.
function allowedMins($min){
	return in_array($min, range(5, 60, 5));
}

// returns a unique user code at the expense of having to make a db request
function genUser($con){
    do {
        $code = generateRandomString(7, true); // 33^7 = 42,618,442,977 possible users
    }while(!userCodeAvailable($con, $code));

    return $code;
}

function userCodeAvailable($con, $code){
    //make sure a user doesn't already have this $code
    $check_users= mysqli_query($con, "
    SELECT id 
    FROM `user`
    WHERE user = '" . myHash($code) . "'
    ");
    if(mysqli_num_rows($check_users) > 0) return false;

    //make sure a perm user does not have this $code
    if(isPermCode($con, $code)) return false;

    return true;
}

function isPermCode($con, $code){
    $check_pros= mysqli_query($con, "
    SELECT id 
    FROM `pro`
    WHERE permUserCode = '" . myHash($code) . "'
    ");
    if(mysqli_num_rows($check_pros) > 0) return true;
    return false;
}

// Returns true if the user code is 7 chars long and consists of only capitals and numbers
function validUserFormat($user){
	if(strlen($user) != 7){
		return false;
	}

	if (preg_match('/[^A-Z0-9]/', $user)) //string doesn't contain only caps and numbers
	{
		return false;
	}

	return true;
}

function getPermUserCode($con, $UUID, $perm_user_code){

	$query = mysqli_query($con, "SELECT permUserCode 
	FROM `pro`
	WHERE UUID = '".myHash($UUID)."'
	AND permUserCode = '".myHash($perm_user_code)."'
	");

	if(mysqli_num_rows($query) > 0){
		return true;
	}
	return false;
}

// gets the total payments of the user
function getTotalUserPayments($con, $hashedUUID){
	$get_credit = mysqli_query($con,"SELECT SUM(credit) as total_credit
	FROM `pro`
	WHERE UUID = '$hashedUUID'");

	while ($row = mysqli_fetch_array($get_credit)) {
		return floatval($row['total_credit']);
	}
	return 0;
}

//!important algorithm to calculate the total bandwidth a user should get based on credit.
function creditToMaxFileUploadSize($credit){
	if($credit > 0) return $credit * 1000;
	return 0;
}

function creditToUploadBandwidth($credit){
	global $daily_allowed_free_user_bandwidth, $file_upload_size_to_bandwidth_constant;

	if(!$daily_allowed_free_user_bandwidth) die("cant get $daily_allowed_free_user_bandwidth");

	$tmp_credit = 0;
	$bandwidth = $daily_allowed_free_user_bandwidth;
	while ($credit >= $tmp_credit){
		$bandwidth += megaToBytes(creditToMaxFileUploadSize($tmp_credit)) * $file_upload_size_to_bandwidth_constant;
		$tmp_credit += 0.5;
	}
	return $bandwidth;
}

function uploadBandwidthToCredit($bandwidth){
	global $daily_allowed_free_user_bandwidth, $file_upload_size_to_bandwidth_constant;

	$credit = 0;
	$tmp_bandwidth = $daily_allowed_free_user_bandwidth;
	while($bandwidth > $tmp_bandwidth){
		$credit += 0.5;
		$tmp_bandwidth += megaToBytes(creditToMaxFileUploadSize($credit)) * $file_upload_size_to_bandwidth_constant;
	}

	return $credit;
}

// returns all the bytes the user has ever used to upload
// unless the user is a free one where the total bandwidth is counted daily
function getTotalUserBandwidth($con, $hashedUUID, $free_user = false){
	$addSQL = "";
	if($free_user){
		// only find bandwidth used today and where bandwidth wasn't used by pro
		$addSQL = "AND DATE(`finished`) = CURDATE()
				   AND `pro` = 0";
	}
	$get_bandwidth = mysqli_query($con,"SELECT SUM(size) as used_bandwidth
	FROM `upload`
	WHERE fromUUID = '$hashedUUID' $addSQL");
	while ($row = mysqli_fetch_array($get_bandwidth)) {
		return floatval($row['used_bandwidth']);
	}
	return 0;
}

function getBandwidthLeft($con, $hashedUUID){
	$daily_allowed_free_user_bandwidth = megaToBytes(2500);

	$total_user_credit = getTotalUserPayments($con, $hashedUUID);
    customLog($total_user_credit." = = ", true);
	$total_bandwidth = creditToUploadBandwidth($total_user_credit);
	$used_bandwidth = getTotalUserBandwidth($con, $hashedUUID);

	$bandwidth_left = $total_bandwidth - $used_bandwidth;

	if($bandwidth_left <= $daily_allowed_free_user_bandwidth) {
	    // is a free user
		$bandwidth_used_today = getTotalUserBandwidth($con, $hashedUUID, true);
		$bandwidth_left = $daily_allowed_free_user_bandwidth - $bandwidth_used_today;
	}

	if($bandwidth_left < 0) return 0; //prevents negative bandwidth left. (should be impossible anyway)

	return $bandwidth_left;
}

function getMaxUploadSize($bandwidth_left){
	global $daily_allowed_free_user_bandwidth, $default_max_file_upload;

    customLog("$daily_allowed_free_user_bandwidth 33333 $default_max_file_upload",true);
	if ($bandwidth_left > $daily_allowed_free_user_bandwidth) {
		$rounded_credit = ceil(uploadBandwidthToCredit($bandwidth_left) * 2) / 2; //rounds up credit to 50p
		return megaToBytes(creditToMaxFileUploadSize($rounded_credit));
	}else if($bandwidth_left > $default_max_file_upload){
		//free user
        customLog("3",true);
		return $default_max_file_upload;
	}

	return $bandwidth_left;
}

function getUserMaxUploadSize($con, $hashedUUID){
	$bandwidth_left = getBandwidthLeft($con, $hashedUUID);
	return getMaxUploadSize($bandwidth_left);
}

function userTier($hashedUUID){
    global $custom_user_credit_min, $perm_user_credit_min;
    $user_credit = getTotalUserPayments(connect(), $hashedUUID);

    if($user_credit >= $custom_user_credit_min){
        return 3;
    }else if($user_credit >= $perm_user_credit_min){
        return 2;
    }else if($user_credit > 0){
        return 1;
    }
    return 0;
}

function userMaxMins($hashedUUID){
    global $default_max_mins;

    $tier = userTier($hashedUUID);
    if($tier == 3){
        return 60;
    }else if($tier == 2){
        return 30;
    }else if($tier == 1){
        return 20;
    }

    return $default_max_mins;
}

// Updates the `updated` time in the `upload` database.
// This is so that the file is not deleted if a user is still downloading or uploading a file.
// see: deleteIncompleteUploads.php to see how the `updated` param is used
function updateUploadTime($con, $aUUID, $path){
	$sql_where_query = "WHERE (fromUUID = '$aUUID'
    OR toUUID = '$aUUID')
    AND path='$path'";

	$exists_query = mysqli_query($con, "SELECT `id` FROM `upload` $sql_where_query");
	if(mysqli_num_rows($exists_query) == 1) {
        $update_query = mysqli_query($con, "UPDATE `upload`
        SET updated = NOW() $sql_where_query");

        if ($update_query) {
            return true;
        }
    }

    return false;
}

function isLiveUpload($con, $path, $fromUUID, $toUUID){
    $query = mysqli_query($con, "SELECT *
    FROM `upload`
    WHERE fromUUID = '$fromUUID'
    AND toUUID = '$toUUID'
    AND path = '$path'
    AND finished IS NULL
    ");

    if(mysqli_num_rows($query) > 0){
        return true;
    }

    return false;
}

// Removes unimportant information on the upload and
// the actual directory of where the file was located using "Secure Remove"
function deleteUpload($con, $toUUID, $fromUUID, $path, $failed){
	if(strlen(trim($path)) > 0) {
        $dir = addDirPath($path);
        if (deleteDir($dir)) {
            $query = mysqli_query($con, "UPDATE `upload`
            SET toUUID = NULL, path = NULL, finished = NOW(), password = NULL, partialKey = NULL, hash = NULL, failed = '" . (int)$failed . "'
            WHERE fromUUID = '$fromUUID'
            AND toUUID = '$toUUID'
            AND path = '$path'
            ");

            if ($query) {
                return true;
            }
        }
	}
    return false;
}

//returns the id of the row in the `upload` database
//also authenticates variables
function getUploadID($con, $fromUUID){
	//pick newest id
    $upload_id_query = mysqli_query($con, "
    SELECT id
    FROM `upload`
	WHERE fromUUID = '$fromUUID'
	ORDER BY id DESC
    ");

    while ($row = mysqli_fetch_array($upload_id_query)){
        return $row['id'];
    }
    return null;
}

//adds the full path to the directory of the path stored in the database
function addDirPath($path){
	global $upload_dir;
	return $upload_dir.$path.'/';
}

//returns the path stored in the database.
function removeDirPath($path){
	global $upload_dir;
	return strtok(str_replace($upload_dir, "", $path),"/");
}

//Deletes a directory with "Secure Delete"
function deleteDir($dir){
//	$command = "sudo /var/www/transferme.it/secureDeleteFolder.sh '$dir'";
//	$shell = trim(shell_exec($command));
//	if($shell == "1") return true;
//	return false;
    array_map('unlink', glob("$dir/*.*"));
    @rmdir($dir);
    return true;
}

// $to = the uuid you are sending to
// $type = is the
function sendLocalSocket($to, $message){
    $mess = json_encode(array("to" => $to, "message" => "$message"));
	$context = new ZMQContext();
	$socket = $context->getSocket(ZMQ::SOCKET_PUSH);
	$socket->connect("tcp://localhost:47802");
	$socket->send($mess);
}

function generateRandomString($length, $forUser = false) {
    $characters = '123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if($forUser) $characters = '123456789ABCDEFGHJKMNOPQRSTUVWXYZ'; //removed 'I' and 'L'
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function customLog($message, $silent=false, $file = 'server.log'){
    global $log_path;
    $file_path = "${log_path}$file";

	$message = date("Y-m-d H:i:s")."\t $message";

	//output log
	if(!$silent) echo $message."\n";

	//store log
	file_put_contents($file_path, $message.PHP_EOL , FILE_APPEND | LOCK_EX);
}

//ip database
function addIP($con){
	$ip = $_SERVER['REMOTE_ADDR'];
	return mysqli_query($con,"INSERT INTO 
	`IPs` (ip) VALUES ('$ip')
  	ON DUPLICATE KEY UPDATE last_access = NOW();");
}

// only allow a new user every $brute_seconds from IP
function notBrute($con){
    global $brute_seconds;
    $ip = $_SERVER['REMOTE_ADDR'];

    $isBrute = mysqli_query($con,"SELECT last_access
    FROM `IPs`
    WHERE ip = '$ip'");
    while ($row = mysqli_fetch_array($isBrute)) {
        $endTime = date("Y-m-d H:i:s", strtotime($row['last_access'] . " +" . $brute_seconds . " seconds"));
        $now = date("Y-m-d H:i:s");

        if (new DateTime($now) <= new DateTime($endTime)) {
            return strtotime($endTime) - strtotime($now);
        }
    }
    return false;
}

//convert megabytes to bytes
function megaToBytes($bytes){
	return $bytes * 1000000;
}

//convert bytes to megabytes
function bytesToMega($bytes){
	return $bytes / 1000000;
}

//calculate the size of a file encrypted with aes on the client side
// RNCryptor
function encryptedFileSize($bytes){
	$overhead = 66;

	if ($bytes == 0)  return 16 + $overhead;

	$remainder = $bytes % 16;
	if ($remainder == 0) return $bytes + 16 + $overhead;

	return $bytes + 16 - $remainder + $overhead;
}

function myHash($str){
    return hash("sha256",$str);
}

function errorDie($mess){
    die(json_encode(array(
        "type" => "error",
        "message" => $mess
    )));
}

/* sanitize user input from php:
    - escapes special chars
    - removes white space
*/
function san($con, $var){
    return trim(mysqli_real_escape_string($con, $var));
}
?>