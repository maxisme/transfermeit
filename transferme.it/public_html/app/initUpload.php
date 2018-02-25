<?php 
session_start();

error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database  
$con = connect();

//initial variables
$friend = san($con, $_POST['friend']);
$UUID = san($con, $_POST['UUID']);
$file_size = san($con, $_POST['filesize']);
$UUIDKey = san($con, $_POST['UUIDKey']);

//validate inputs
if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
	die('1');
}

$friendUUID = userToHashedUUID($con, $friend);
if($friendUUID == null){
    if(isPermCode($con, $friend)){
        errorDie('Your friend is not online!');
    }else{
        errorDie('Your friend does not exist!');
    }
}

$userUUID = myHash($UUID);
if($friendUUID == $userUUID){
    errorDie('You can\'t send files to yourself!');
}

//check if file size is allowed user single file limit
$max_file_allowed_bytes = getUserMaxUploadSize($con, $userUUID);
if($file_size > encryptedFileSize($max_file_allowed_bytes)){
    errorDie("This file exceeds your ".bytesToMega($max_file_allowed_bytes)."MB upload limit.");
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
            errorDie("Failed to delete file that you are already uploading to your friend.");
        }
	}
}

//create upload folder at random path
$path = generateRandomString(200);
$dir = addDirPath($path);
if(!mkdir($dir)){
    errorDie("Unable to create directory: $dir");
}

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
    errorDie("Could not insert upload details into database");
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
    errorDie("Your friend does not have a public key");
}

//store session variable for upload path - this also makes sure it is not possible to run upload.php without initUpload.php
$_SESSION["path".$upload_id] = $path;
$_SESSION["filesize".$upload_id] = $file_size;
$_SESSION["friendUUID".$upload_id] = $friendUUID;

die(json_encode(array(
    "type" => "key",
    "pub_key" => $pubKey
)));

?>