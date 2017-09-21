<?php 
session_start();

error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database  
$con = connect();

//initial variables
$user = mysqli_real_escape_string($con, $_POST['user']);
$friend = mysqli_real_escape_string($con, $_POST['friend']); 
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$file_size = mysqli_real_escape_string($con, $_POST['filesize']);
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);

//validate inputs
if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
	die('1');
}

$userUUID = userToHashedUUID($con, $user);
if($userUUID == null){ 
	die('2');
}

$friendUUID = userToHashedUUID($con, $friend);
if($friendUUID == null){
	die('Your friend does not exist!');
}

//if(!ctype_digit((int)$file_size)){
//    die('6');
//}

//check if file size is allowed user single file limit
$max_file_allowed_bytes = getMaxUploadSize($con, $userUUID);
if($file_size > encryptedFileSize($max_file_allowed_bytes)){
	die("This file is out of your ".bytesToMega($max_file_allowed_bytes)."MB upload limit. Please buy more credit.");
}

//check if user and friend are already uploading to each other
$isAlreadyUploading = mysqli_query($con,"SELECT path
FROM `upload`
WHERE fromUUID = '$userUUID'
AND toUUID = '$friendUUID'");
while ($row = mysqli_fetch_array($isAlreadyUploading)) {
	if($row['path'] != null){
	    // user is already uploading a file to this friend
        // so delete it
        if(!deleteUpload($con, $userUUID, $friendUUID, $row['path'], true)){
            die("Failed to delete file that you are already uploading to your friend.");
        }
	}
}

//create upload folder at random path
$path = generateRandomString(200);
$dir = addDirPath($path);
mkdir($dir, 0775, true);

//check if upload is being made by a pro user
$pro_upload = 0;
if($max_file_allowed_bytes > $default_max_file_upload){
	$pro_upload = 1;
}

//insert initial `upload` row
if(!mysqli_query($con, "
INSERT INTO `upload` (fromUUID, toUUID, path, pro)
VALUES ('$userUUID', '$friendUUID', '$path', '$pro_upload')")){
    customLog("Could not insert upload details: " . mysqli_error($con), TRUE);
	die("Could not insert upload details into database");
}

//get upload id
$upload_id = mysqli_insert_id($con);
if(!$upload_id) die("unable to get last row id");

//get friends public key
$isAlreadyUploading = mysqli_query($con,"SELECT pubKey 
FROM `user`
WHERE UUID = '$friendUUID'");
$pubKey = NULL;
while ($row = mysqli_fetch_array($isAlreadyUploading)) {
    $pubKey = $row['pubKey'];
}

if(!$pubKey){
    die("Your friend does not have a public key");
}

////send key directly over socket to friendID
//sendLocalSocket($friendUUID, json_encode(array(
//    "type" => "key",
//    "ref" => $upload_id
//)));

//store session variable for upload path - this also makes sure it is not possible to run upload.php without initUpload.php
$_SESSION["path".$upload_id] = $path;
$_SESSION["filesize".$upload_id] = $file_size;
$_SESSION["friendUUID".$upload_id] = $friendUUID;

die(json_encode(array(
    "type" => "key",
    "pub_key" => $pubKey
)));

?>