<?php
require 'functions.php';

//connect to database
$con = connect();

//initial variables
$friendUUID = mysqli_real_escape_string($con, $_POST['friendUUID']);
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$path = mysqli_real_escape_string($con, $_POST['path']);
$fileHash = trim(mysqli_real_escape_string($con, $_POST['hash']));
$ref = trim(mysqli_real_escape_string($con, $_POST['ref']));

if (!UUIDRegistered($con, $UUID)) {
	die('1');
}

if(!is_numeric($ref)){
    die("2");
}

$userUUID = myHash($UUID);

$db_path = removeDirPath($path);

if(!isLiveUpload($con, $db_path, $friendUUID, $userUUID)){
    die('3');
}

$partialKey = 0;
$failed = true;
//get other part of encryption key
if(!empty($fileHash)){
	$partialKeyQuery = mysqli_query($con, "SELECT partialKey
	FROM `upload`
	WHERE fromUUID = '$friendUUID'
	AND toUUID = '$userUUID'
	AND path = '$db_path'
	AND `hash` = '$fileHash'
	AND `id` = '$ref'");

	$partialKey = null;
	while ($row = mysqli_fetch_array($partialKeyQuery)) {
        // succesfully finished download as user has hash
		$partialKey = $row['partialKey'];
	}

	if($partialKey == null){
		die("SELECT partialKey
	FROM `upload`
	WHERE fromUUID = '$friendUUID'
	AND toUUID = '$userUUID'
	AND path = '$db_path'
	AND `hash` = '$fileHash'
	AND `id` = '$ref'");
	}

	$failed = false;
}

//finished upload
if(deleteUpload($con, $userUUID, $friendUUID, $db_path, $failed)){
	//send message to uploader that file has been downloaded by user successfully
	sendLocalSocket("downloaded|$friendUUID|$path");
	die($partialKey);
}else{
	echo "Failed to delete file: ".$db_path;
}
?>