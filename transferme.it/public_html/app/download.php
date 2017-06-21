<?php 
function downloadFile($file){
	ob_end_clean();
	header("Connection: close");
	ignore_user_abort(true);
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
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);
$path = mysqli_real_escape_string($con, $_POST['path']);

//validation
if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
	die("1");
}

$db_path = removeDirPath($path);

if(updateUploadTime($con, myHash($UUID), $db_path)) {
    downloadFile($path);
}else{
    die("2");
}
?>