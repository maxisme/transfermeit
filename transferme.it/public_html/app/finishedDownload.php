<?php
/* security check list:
    - UUIDRegistered() success followed by select statement guarantees that the file was 100% destined
      for this user.
    - sql
*/
require 'functions.php';

//connect to database
$con = connect();

//initial variables
$friendUUID = san($con, $_POST['friendUUID']);
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);
$path = san($con, $_POST['path']);
$fileHash = san($con, $_POST['hash']);
$ref = san($con, $_POST['ref']);

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
    if($failed) {
        $title = "Unsuccessful download";
        $mess = "Your friend may have ignored the download or there was an error.";
    }else{
        $title = "Successful Download";
        $mess = "Your friend successfully downloaded the file!";
    }
    sendLocalSocket($friendUUID, json_encode(array("type" => "downloaded", "title" => "$title", "message" => "$mess")));

    if ($failed) die("failed");
    die($encrypted_pass); // return encrypted password for file
}else{
	echo "Failed to delete file: ".$db_path;
}
?>