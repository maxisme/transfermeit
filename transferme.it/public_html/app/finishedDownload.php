<?php
require 'functions.php';

//connect to database
$con = connect();

//initial variables
$user = mysqli_real_escape_string($con, $_POST['user']);
$friendUUID = mysqli_real_escape_string($con, $_POST['friendUUID']);
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$path = mysqli_real_escape_string($con, $_POST['path']);
$fileHash = trim(mysqli_real_escape_string($con, $_POST['hash']));

if (!UUIDRegistered($con, $UUID)) {
	die('1');
}

$userUUID = userToHashedUUID($con, $user);
if($userUUID == null){
	die('2');
}

//extra validation check if user variables "match up"
$upload_id = getUploadID($con, $friendUUID, $userUUID);
if($upload_id == null){
	die("3");
}

$db_path = removeDirPath($path);

$partialKey = 0;
$failed = true;
if(!empty($fileHash)){ // succesfully finished download
	//get other part of encryption key
	$partialKeyQuery = mysqli_query($con, "SELECT partialKey
	FROM `upload`
	WHERE fromUUID = '$friendUUID'
	AND toUUID = '$userUUID'
	AND path = '$db_path'
	AND `hash` = '$fileHash'");

	$partialKey = null;
	while ($row = mysqli_fetch_array($partialKeyQuery)) {
		$partialKey = $row['partialKey'];
	}

	if($partialKey == null){
		die("SELECT partialKey
		FROM `upload`
		WHERE fromUUID = '$friendUUID'
		AND toUUID = '$userUUID'
		AND path = '$db_path'
		AND `hash` = '$fileHash'");
	}

	$failed = false;
}

//finished upload
if(deleteUpload($con, $userUUID, $friendUUID, $db_path, $failed)){
	//send message to uploader that file has been downloaded.
	sendLocalSocket("downloaded|$friendUUID|$path");
	die($partialKey);
}else{
	echo "Failed to delete file: ".$db_path;
}
?>