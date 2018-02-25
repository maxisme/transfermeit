<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);
$creditCode = san($con, $_POST['credit_code']);

if (!UUIDRegistered($con, $UUID, $UUIDKey)) die('1');

if(strlen($creditCode) != 100 || hasSpecialChars($creditCode)) die('2');

$result = mysqli_query($con,"
SELECT * 
FROM `pro`
WHERE `code` = '$creditCode'
AND activation IS NULL
AND UUID IS NULL");

if(mysqli_num_rows($result) > 0) {
	//there is a pro code that has not been used
	$updatePro = mysqli_query($con, "UPDATE `pro`
	SET UUID = '".myHash($UUID)."', activation = NOW()
	WHERE code = '$creditCode'");

	if($updatePro){
		die("0");
	}else{
		die("4");
	}
}else{
	die("3");
}
?>