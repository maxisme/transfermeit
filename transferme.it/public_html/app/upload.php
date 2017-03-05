<?php
session_start();
//ini set in /etc/php5/fpm/php.ini
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
		die("$error_num - error deleting upload");
	}
}

//connect to database 
$con = connect();

//initial variables
$user = mysqli_real_escape_string($con, $_POST['user']);
$friend = mysqli_real_escape_string($con, $_POST['friend']);
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);

//validate inputs (not really necessary to do again)
if (!UUIDRegistered($con, $UUID)) {
	uploadDie('01');
}

$userUUID = userToHashedUUID($con, $user);
if($userUUID == null){
	uploadDie('02');
}

$friendUUID = userToHashedUUID($con, $friend);
if($friendUUID == null){
	uploadDie('03');
}

// get upload_id
$upload_id = getUploadID($con, $userUUID, $friendUUID);
if($upload_id == null){
	uploadDie("4");
}

// get file path
$upload_path = $_SESSION["path".$upload_id];
if(!isset($upload_path)){
	//initUpload.php was probably not used.
	uploadDie("4");
}
$file_path = getDirPath($upload_path) . basename($_FILES["fileUpload"]["name"]);

// validate file size and make sure it is the same as the one in innit
$said_file_size = $_SESSION["filesize".$upload_id];
if($said_file_size){
	if ($_FILES["fileUpload"]["size"] != $said_file_size) {
		//file is too big
		uploadDie("2 said:$said_file_size actual: ".$_FILES["fileUpload"]["size"]);
	}
}else{
	uploadDie('5');
}

// upload file
if (!move_uploaded_file($_FILES["fileUpload"]["tmp_name"], $file_path)) {
	uploadDie('6');
}else{
	//get sha512 of file
	$fileHash = hash_file("sha512", "$file_path");

	// set upload size
	if(!mysqli_query($con, "UPDATE `upload`
	SET size = '$said_file_size', `hash` = '$fileHash'
	WHERE fromUUID = '$userUUID'
	OR toUUID = '$friendUUID'
	AND path='$upload_path'")){
		uploadDie('7');
	}

	// update `updated` time
	updateUploadTime($con, $userUUID, $upload_path);

	//successfully uploaded file
	sendLocalSocket("file|$friendUUID|$file_path|$upload_id|$userUUID");
	echo "1";
}