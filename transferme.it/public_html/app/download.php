<?php 
function downloadPath($file){
	ob_end_clean();
	header("Connection: close");
	ignore_user_abort(true); // just to be safe
	header('Content-Type: application/octet-stream');
	header('Content-Transfer-Encoding: binary');
	header('Expires: 0');
	header('Content-Length: ' . filesize($file));
	readfile($file);
}

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$friendUUID = mysqli_real_escape_string($con, $_POST['friendUUID']);
$user = mysqli_real_escape_string($con, $_POST['user']);
$path = mysqli_real_escape_string($con, $_POST['path']);

if (!UUIDRegistered($con, $UUID)) {
	die('1');
}

$userUUID = userToHashedUUID($con, $user);
if($userUUID == null){
	die('2');
}

$db_path = removeDirPath($path);

// no such upload
if(!isLiveUpload($con, $db_path, $friendUUID)){
    die('3');
}

updateUploadTime($con, $userUUID, $db_path);

downloadPath($path);
?>