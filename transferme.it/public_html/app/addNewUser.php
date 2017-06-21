<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

if (!@fsockopen('127.0.0.1', 48341)) {
    die(json_encode(array( "status" => "socket_down")));
}

require 'functions.php';

//connect to database
$con = connect();

//variables
$key_len = 100;
$max_allowed_mins = $default_max_mins;

//POST
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$wantedMins = mysqli_real_escape_string($con, $_POST['mins']);
if (isset($_POST['perm_user'])) $perm_user = $_POST['perm_user'];

//validate inputs
if (!validUUID($UUID)) {
	//not valid UUID
    die(json_encode(array("status" => "invalid_uuid")));
}

if(!allowedMins($wantedMins)){
	//not in array of allowed times
    die(json_encode(array("status" => "invalid_mins")));
}

//generate unique code for user
$user = genUser();

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
	$UUIDKey = $row['UUIDKey'];
}

$brute = isBrute($con);

if(mysqli_num_rows($queryNewUser) == 0) {
    addIP($con);
    $secureUUIDKey = generateRandomString($key_len);
    //if UUID doesn't exist this is the first time using transferme.it on device
    //create initial account
    $query = mysqli_query($con, "
	INSERT INTO `user` (user, UUID, UUIDKey, created, registered)
	VALUES ('" . myHash($user) . "', '" . myHash($UUID) . "','" . myHash($secureUUIDKey) . "', NOW(), NOW());");

    if (!$query) {
        echo("Error description: " . mysqli_error($con));
    } else {
        $arr = array(
            "user_code" => "$user",
            "bandwidth_left" => "$free_user_bandwidth",
            "mins_allowed" => "$max_allowed_mins",
            "user_tier" => "0",
            "UUID_key" => "$secureUUIDKey"
        );
        die(json_encode($arr));
    }
}else{
    addIP($con);
	$hashedUser = myHash($user);

	//get perm user code if exists
	if (!empty($perm_user) && $UUIDKey != myHash(" ")) {
		$pro_user_info = mysqli_query($con, "
		SELECT perm_user
		FROM `pro`
		WHERE UUID = '" . myHash($UUID) . "'
		AND credit >= '$perm_user_credit_min'
		ORDER BY created ASC
		LIMIT 1
		"); //pick oldest first

		if (mysqli_num_rows($pro_user_info) > 0) {
			while ($row = mysqli_fetch_array($pro_user_info)) {
				if (isset($row['perm_user'])) {
					if (myHash($perm_user) == $row['perm_user']) {
						//perm_code is what the user says
						$hashedUser = $row['perm_user'];
						$user = $perm_user;
					}
				}
			}
		}
	}

	//validate mins
	$userMaxMins = userMaxMins(myHash($UUID));
	if ($wantedMins > $userMaxMins) {
		//over limit
		$wantedMins = $userMaxMins;
	}

	//update user data into db
	$query = mysqli_query($con, "
	UPDATE `user` 
	SET user = '$hashedUser', wantedMins = '$wantedMins', created = NOW()
	WHERE UUID = '" . myHash($UUID) . "';
	");

	if (!$query) {
		die("04");
	} else {
		$arr = array(
			"user_code" => "$user",
			"bandwidth_left" => getBandwidthLeft($con, myHash($UUID)),
			"mins_allowed" => "$userMaxMins",
			"user_tier" => userTier(myHash($UUID))
		);
		die(json_encode($arr));
	}
}
//else{
//    $arr = array(
//        "status" => "brute",
//        "brute_left" => $brute
//	);
//    die(json_encode($arr));
//}
?>
