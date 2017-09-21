<?php
session_start();
// ini set in /etc/php7.1/fpm/php.ini
// max_execution_time set from 30 to 0
// post_max_size set from 8M to 5000M

error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

function uploadDie($error_num){
	global $con, $user, $friend, $upload_path;

	if(deleteUpload($con, $user, $friend, $upload_path, true)) {
		die("$error_num");
	}else {
		die("$error_num - error deleting upload - ". $_SERVER["CONTENT_LENGTH"]);
	}
}

//connect to database 
$con = connect();

//initial variables
$user = mysqli_real_escape_string($con, $_POST['user']);
$friend = mysqli_real_escape_string($con, $_POST['friend']);
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);
$pass = mysqli_real_escape_string($con, $_POST['pass']);

//validate inputs (not really necessary to do again)
if (!UUIDRegistered($con, $UUID, $UUIDKey)) uploadDie('1');

$userUUID = userToHashedUUID($con, $user);
if($userUUID == null) uploadDie('2');

$upload_id = getUploadID($con, $userUUID);
if($upload_id == null) uploadDie("4");

// get friendUUID from session
$friendUUID = $_SESSION["friendUUID".$upload_id];
//initUpload.php was probably not used.
if(!isset($friendUUID)) uploadDie("5");

// get file path from session
$upload_path = $_SESSION["path".$upload_id];
if(!isset($upload_path)) uploadDie("6"); //initUpload.php won't have been used.

//no such upload initiated
if(!isLiveUpload($con, $upload_path, $userUUID, $friendUUID)) die('7');

//validate password
if(empty($pass)) uploadDie("8");

$file_name = basename($_FILES["fileUpload"]["name"]);
$file_path = addDirPath($upload_path) . $file_name;

// validate file size and make sure it is the same as the one in innit
$said_file_size = $_SESSION["filesize".$upload_id];
if($said_file_size){
	if ($_FILES["fileUpload"]["size"] > $said_file_size) { //greater than as compression is applied
		//file is too big
		uploadDie("2 said:$said_file_size actual: ".$_FILES["fileUpload"]["size"]);
	}
}else{
	uploadDie('9');
}

// upload file
if (!move_uploaded_file($_FILES["fileUpload"]["tmp_name"], $file_path)) {
	uploadDie('10');
}else{
	//get sha512 of file
	$fileHash = hash_file("sha512", "$file_path");

	// set upload size
	if(!mysqli_query($con, "UPDATE `upload`
	SET size = '$said_file_size', `hash` = '$fileHash', `password` = '$pass'
	WHERE fromUUID = '$userUUID'
	AND toUUID = '$friendUUID'
	AND path='$upload_path'")){
		uploadDie('11');
	}

	// update `updated` time
	updateUploadTime($con, $userUUID, $upload_path);

	customLog("upload_id: $upload_id",TRUE);

	//successfully uploaded file - now tell friend to download
	sendLocalSocket($friendUUID, json_encode(array(
	    "type"  => "download",
        "path"  => $file_path,
        "ref"   => $upload_id,
        "UUID"  => $userUUID
    )));
	echo "1";
}