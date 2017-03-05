<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$pro_code = trim(mysqli_real_escape_string($con, $_POST['code']));

if (!UUIDRegistered($con, $UUID)) {
	die('1');
}

if(strlen($pro_code) != 100 || hasSpecialChars($pro_code)){
	die('2');
}

$result = mysqli_query($con,"
SELECT * 
FROM `pro`
WHERE code = '$pro_code'
AND activation != NULL
AND expiry > NOW()");

if(mysqli_num_rows($result) > 0) {
	//there is a pro code that has not been used, and has not expired in the db
	$updatePro = mysqli_query($con, "UPDATE `pro`
	SET UUID = '".myHash($UUID)."', activation = NOW()
	WHERE code = '$pro_code'");

	if($updatePro){
		die("0");
	}else{
		die("4");
	}
}else{
	die("3");
}
?>