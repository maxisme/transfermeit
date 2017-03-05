<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$remove_perm_code = false;
$allowed_custom_code = false;
//POST variables
if(isset($_POST['customCode'])) {
	$customCode = trim(mysqli_real_escape_string($con, $_POST['customCode']));
	if($customCode == "0"){
		$remove_perm_code = true;
	}else if(!validUserFormat($customCode)){
		die('2');
	}
}
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$pro_code = mysqli_real_escape_string($con, $_POST['pro_code']);

if(strlen($pro_code) != 100 || hasSpecialChars($pro_code)){
	die("3");
}

if (!UUIDRegistered($con, $UUID)) {
	die('4');
}

if(!isProUser($con, $pro_code, $UUID)){
	die("5");
}

$query = mysqli_query($con, "
SELECT *
FROM `pro`
WHERE code = '$pro_code'
");

while ($row = mysqli_fetch_array($query)){
	if($row['maxLimitMB'] >= $custom_pro_mb){
		//user is allowed a CUSTOM CODE
		$allowed_custom_code = true;
	}
}

if($remove_perm_code){
	//stop using perm user code
	if(!mysqli_query($con,"UPDATE `pro`
	SET perm_user = NULL
	WHERE code = '$pro_code'")){
		//failed to update pro code
		die("5");
	}else{
		die("1");
	}
}else{
	if(!$allowed_custom_code || !isset($_POST['pro_code'])){
		$customCode = genUser();
	}

	if(!mysqli_query($con,"UPDATE `pro`
	SET perm_user = '".myHash($customCode)."'
	WHERE code = '$pro_code'")){
		die("6");
	}
}

echo "0$customCode";

?>