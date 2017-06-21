<?php
require 'functions.php';

//connect to database
$con = connect();

//initial variables
$friendUUID = mysqli_real_escape_string($con, $_POST['friendUUID']);
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);
$path = mysqli_real_escape_string($con, $_POST['path']);
$fileHash = trim(mysqli_real_escape_string($con, $_POST['hash']));
$ref = trim(mysqli_real_escape_string($con, $_POST['ref']));

if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
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

$partialKey = "";
$failed = true;
//get other part of encryption key
if(!empty($fileHash)){
    $failed = false;

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
		$failed = true;
	}
}

//finished upload
if(deleteUpload($con, $userUUID, $friendUUID, $db_path, $failed)) {
    //send message to uploader that file has been downloaded by user successfully
    if($failed) {
        $title = "Error with friend download";
        $mess = "Try send the file again";
    }else { 
        $title = "Successful Download";
        $mess = "Your friend successfully downloaded and decrypted the file!";
    }

    sendLocalSocket($friendUUID, json_encode(array("type" => "downloaded", "title" => $title, "message" => "$mess")));

    if (!$failed) die($partialKey);
    die("1");
}else{
	echo "Failed to delete file: ".$db_path;
}
?>