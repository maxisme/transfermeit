<?php
session_start();
// ini set in /etc/php7.1/fpm/php.ini
// max_execution_time set from 30 to 0
// post_max_size set from 8M to 5000M

error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

function uploadDie($error_num){
	global $con, $userUUID, $promisedFriendUUID, $promisedUploadPath;

	if(deleteUpload($con, $userUUID, $promisedFriendUUID, $promisedUploadPath, true)) {
		die("$error_num");
	}else {
		die("$error_num - error deleting upload - ". $_SERVER["CONTENT_LENGTH"]);
	}
}

//connect to database 
$con = connect();

//initial variables
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);
$pass = san($con, $_POST['pass']);

//validate inputs (not really necessary to do again)
if (!UUIDRegistered($con, $UUID, $UUIDKey)) uploadDie('1');

$userUUID = myHash($UUID);

$upload_id = getUploadID($con, $userUUID);
if($upload_id == null) uploadDie("4");

// get friendUUID from session
$promisedFriendUUID = $_SESSION["friendUUID".$upload_id];
if(!isset($promisedFriendUUID)) uploadDie("5"); //initUpload.php was not successful.

// get file path from session
$promisedUploadPath = $_SESSION["path".$upload_id];
if(!isset($promisedUploadPath)) uploadDie("6"); //initUpload.php was not successful.

// no such upload initiated
if(!isLiveUpload($con, $promisedUploadPath, $userUUID, $promisedFriendUUID)) die('7');

// validate password
if(empty($pass)) uploadDie("8");

$file_name = basename($_FILES["fileUpload"]["name"]);
$file_path = addDirPath($promisedUploadPath) . $file_name;

// validate file size and make sure it is the same as the one in innit
$promised_file_size = $_SESSION["filesize".$upload_id];
// get actual file size
$actual_file_size = $_FILES["fileUpload"]["size"];
if($promised_file_size){
	if ($actual_file_size > $promised_file_size) { // greater than (rather than equal) as compression may have been applied
		//file is too big
		uploadDie("2 said:$promised_file_size actual: ".$_FILES["fileUpload"]["size"]);
	}
}else{
	uploadDie('9');
}

// upload file
if (!move_uploaded_file($_FILES["fileUpload"]["tmp_name"], $file_path)) {
	uploadDie($file_path);
}else{
	//get sha256 of file
	$fileHash = hash_file("sha256", "$file_path");

	// set upload size
	if(!mysqli_query($con, "UPDATE `upload`
	SET size = '$actual_file_size', `hash` = '$fileHash', `password` = '$pass'
	WHERE fromUUID = '$userUUID'
	AND toUUID = '$promisedFriendUUID'
	AND path = '$promisedUploadPath'")){
		uploadDie('11');
	}

	// update `updated` time
	updateUploadTime($con, $userUUID, $promisedUploadPath);

	customLog("upload_id: $upload_id",TRUE);

	//successfully uploaded file - now tell friend to download
	sendLocalSocket($promisedFriendUUID, json_encode(array(
	    "type"  => "download",
        "path"  => $file_path,
        "ref"   => $upload_id,
        "UUID"  => $userUUID,
        "file-size"  => "$actual_file_size"
    )));
	echo "1";
}