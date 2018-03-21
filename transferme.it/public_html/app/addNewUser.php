<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

//for checking whether user has given a valid public key
require_once "/var/www/transferme.it/public_html/vendor/autoload.php";
use ASN1\Type\Constructed\Sequence;

if (!@fsockopen('127.0.0.1', 48341)) {
    die(json_encode(array( "status" => "socket_down")));
}

require 'functions.php';

// most important check to see if the client knows the encrypted key in the tmi binary
if((string)$_POST['server_key'] != file_get_contents("../../secret_server_code.pass")) die();

//connect to database
$con = connect();

//POST
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);
$wantedMins = san($con, $_POST['mins']);
$pubKey = san($con, $_POST['pub_key']);
$permCode = $_POST['perm_user_code'];

//validate inputs
if (!validUUID($UUID)) {
	//not valid UUID
    die(json_encode(array("status" => "invalid_uuid")));
}

// Check pub key is actually an RSA key
// works by checking whether the oid matches the key type -> http://www.alvestrand.no/objectid/1.2.840.113549.1.1.1.html
$str = base64_decode($pubKey);
$seq = Sequence::fromDER($str);
$oid = $seq->at(0)->at(0)->oid();
if($oid != "1.2.840.113549.1.1.1") die(json_encode(array("status" => "invalid_pub_key")));

if(!allowedMins($wantedMins)){
	//not in array of allowed times
    die(json_encode(array("status" => "invalid_mins $wantedMins")));
}

//generate unique code for user
$userCode = genUser($con);

//select users account against UUID
$queryNewUser = mysqli_query($con, "
SELECT * 
FROM `user`
WHERE UUID = '".myHash($UUID)."'
LIMIT 1
");

while ($row = mysqli_fetch_array($queryNewUser)){
	$old_user = $row['user'];
	$created = $row['created'];
	$oldWantedMins = $row['wantedMins'];
    $storedUUIDKey = $row['UUIDKey'];
}

// will catch lots of new accounts being created
//if(!notBrute($con)) die(json_encode(array("status" => "brute")));

addIP($con); // used to find "fishy" socket connections and DDOS account creation

if(empty($UUIDKey) && empty($storedUUIDKey)) {
	////////////////////
	// UUIDKey reset.
    ////////////////////

    $secureUUIDKey = generateRandomString($key_len);

    $query = mysqli_query($con, "
	UPDATE `user` 
	SET UUIDKey = '" . myHash($secureUUIDKey) . "'
	WHERE UUID = '" . myHash($UUID) . "';
	");

    if (!$query) {
        echo("Error description: " . mysqli_error($con));
        customLog("Error description 1: " . mysqli_error($con), true, "error.log");
    } else {
        $arr = array(
            "user_code" => $userCode,
            "bw_left" => $daily_allowed_free_user_bandwidth,
            "max_fs" => $default_max_file_upload,
            "mins_allowed" => $max_allowed_mins,
            "user_tier" => 0,
            "UUID_key" => $secureUUIDKey,
            "time_left" => getUserTimeLeft($con, myHash($UUID))
        );
        die(json_encode($arr));
    }

}else if(mysqli_num_rows($queryNewUser) == 0){
    ////////////////////
    // create initial account
    ////////////////////
    $secureUUIDKey = generateRandomString($key_len);

    $query = mysqli_query($con, "
	INSERT INTO `user` (user, UUID, UUIDKey, pubKey, created, registered)
	VALUES ('" . myHash($userCode) . "', '" . myHash($UUID) . "','" . myHash($secureUUIDKey) . "', '".$pubKey."', NOW(), NOW());");

    if (!$query) {
        echo("Error description: " . mysqli_error($con));
        customLog("Error description 2: " . mysqli_error($con), true, "error.log");
    } else {
        $arr = array(
            "user_code" => $userCode,
            "bw_left" => $daily_allowed_free_user_bandwidth,
            "max_fs" => $default_max_file_upload,
            "mins_allowed" => $max_allowed_mins,
            "user_tier" => 0,
            "UUID_key" => $secureUUIDKey,
            "time_left" => getUserTimeLeft($con, myHash($UUID))
        );
        die(json_encode($arr));
    }
}else if (UUIDRegistered($con, $UUID, $UUIDKey)){
    ////////////////////
	/// already exists
	///////////////////

	//get perm user code if exists
    if (!empty($permCode)){
        $userCode = getUserPermCode($con, $UUID, $permCode);
    	if(!$userCode) die(json_encode(array("status" => "perm_code_lie")));
    }

    $hashedUserCode = myHash($userCode);

	// validate user is allowed mins they asked for.
	// if they are not set max they are allowed.
	$userMaxMins = userMaxMins(myHash($UUID));
	if ($wantedMins > $userMaxMins) {
		//over limit
		$wantedMins = $userMaxMins;
	}

	//update user data into db
	$query = mysqli_query($con, "
	UPDATE `user` 
	SET user = '$hashedUserCode', wantedMins = '$wantedMins', created = NOW(), pubKey = '$pubKey'
	WHERE UUID = '" . myHash($UUID) . "';
	");

	if (!$query) {
		die("04");
	} else {
		$bw_left = getBandwidthLeft($con, myHash($UUID));
		$max_fs = getMaxUploadSize($bw_left);
		$arr = array(
			"user_code" => $userCode,
			"bw_left" => $bw_left,
            "max_fs" => $max_fs,
			"mins_allowed" => "$userMaxMins",
			"user_tier" => userTier(myHash($UUID)),
			"time_left" => getUserTimeLeft($con, myHash($UUID))
		);
		die(json_encode($arr));
	}
}else{
    die(json_encode(array("status" => "invalid_UUID_key")));
}
?>
