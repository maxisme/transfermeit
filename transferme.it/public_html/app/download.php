<?php 
function downloadFile($file){
    /* https://stackoverflow.com/questions/138374/close-a-connection-early */
    /* ----- hack ------ */
	ob_end_clean();
	header("Connection: close");
	ignore_user_abort(true);
	/* ----------------- */
	header('Content-Type: application/octet-stream');
	header('Content-Transfer-Encoding: binary');
	header('Expires: 0');
	header('Content-Length: ' . filesize("$file"));
	readfile("$file");
}

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);
$path = $_POST['path'];

//validation
if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
	die("1");
}

if(updateUploadTime($con, myHash($UUID), removeDirPath($path))) {
    downloadFile($path);
}else{
    die("2"); // extremely likely that this is due to an expired download TODO: make it 100% likely
}
?>