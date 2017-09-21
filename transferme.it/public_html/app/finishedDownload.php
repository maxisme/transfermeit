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

$encrypted_pass = null;
$failed = true;

//get encrypted password
if(!empty($fileHash)){
    $failed = false;

	$partialKeyQuery = mysqli_query($con, "SELECT password
	FROM `upload`
	WHERE fromUUID = '$friendUUID'
	AND toUUID = '$userUUID'
	AND path = '$db_path'
	AND `hash` = '$fileHash'
	AND `id` = '$ref'");

    $encrypted_pass = null;
	while ($row = mysqli_fetch_array($partialKeyQuery)) {
        // successfully finished download as user has hash
        $encrypted_pass = $row['password'];
	}

	if($encrypted_pass == null){
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
        $mess = "Your friend successfully downloaded the file!";
    }

    sendLocalSocket($friendUUID, json_encode(array("type" => "downloaded", "title" => $title, "message" => "$mess")));

    if ($failed) die("1");
    die($encrypted_pass); // successful download
}else{
	echo "Failed to delete file: ".$db_path;
}
?>