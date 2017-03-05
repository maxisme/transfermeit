***REMOVED***
***REMOVED***
***REMOVED***

require 'functions.php';

//connect to database
$con = connect();

//store ip of user
addIP($con);

//variables
$key_len = 50;
$max_allowed_mins = $default_max_mins;

//POST
$UUID = mysqli_real_escape_string($con, $_POST['UUID']); 
$wantedMins = mysqli_real_escape_string($con, $_POST['mins']);
$security = mysqli_real_escape_string($con, $_POST['security']);
if (isset($_POST['code'])) $pro_code = $_POST['code'];
if (isset($_POST['perm_user'])) $perm_user = $_POST['perm_user'];

//validate inputs
if (!validUUID($UUID)) {
	//not valid UUID
	die('01'.$UUID);
***REMOVED***

if(!allowedMins($wantedMins)){
	//not in array of allowed times
	die('02');
***REMOVED***

if (!empty($pro_code) && hasSpecialChars($pro_code))
{
	//$pro_code doesn't contain only letters and numbers
	die('03');
***REMOVED***

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
	$created = $row['created'];
	$oldWantedMins = $row['wantedMins'];
	$UUIDKey = $row['UUIDKey'];
***REMOVED***

if(mysqli_num_rows($queryNewUser) == 0){
	//if UUID doesn't exist this is the first time using transferme.it on device
	$query = mysqli_query($con, "
	INSERT INTO `user` (user, UUID, UUIDKey, created, registered)
	VALUES ('".myHash($user)."', '".myHash($UUID)."','".myHash(" ")."', NOW(), NOW());");
	
	if(!$query){
		echo("Error description: " . mysqli_error($con));
	***REMOVED***else{
		die("1$user,$free_user_bandwidth,$max_allowed_mins");
	***REMOVED*** 
***REMOVED***else{
	$has_expired = "1"; // hasn't expired

	//get perm user if exists
	if (!empty($pro_code)) {
		//update user info depending on pro info
		$pro_user_info = mysqli_query($con, "
		SELECT perm_user
		FROM `pro`
		WHERE UUID = '".myHash($UUID)."'
		AND code = '$pro_code'
		");

		if (mysqli_num_rows($pro_user_info) > 0) {
			while ($row = mysqli_fetch_array($pro_user_info)) {
				if(isset($row['perm_user'])) {
					$hashed_perm_user = $row['perm_user'];
				***REMOVED***
			***REMOVED***
		***REMOVED***
		
		if (!isProUser($con, $pro_code, $UUID)) {
			//PRO HAS EXPIRED
			mysqli_query($con, "UPDATE `user`
			SET user = '".myHash($user)."', maxMins = '$max_allowed_mins',
			UUIDKey = '$UUIDKey', created = NOW()
			WHERE UUID = '".myHash($UUID)."'
			AND code = '$pro_code'");
			$has_expired = "2"; // has expired
		***REMOVED***
	***REMOVED***

	//validate mins
	if ($wantedMins > $max_allowed_mins) {
		//asked for too high amount
		$wantedMins = $max_allowed_mins;
	***REMOVED***

	//add security UUIDkey to account
	$addedSQL = "";
	$addedReturn = "";
	if($security == "1" && empty($UUIDKey)) {
		$secureUUIDKey = generateRandomString($key_len);
		//does not already have extra security and asking for extra security
		$addedSQL = ", UUIDKey = '".myHash($secureUUIDKey)."'";
		$addedReturn = ','.$secureUUIDKey;
	***REMOVED***

	if (isset($hashed_perm_user) && strlen($hashed_perm_user) > 0
		&& !empty($perm_code) && myHash($perm_user) == $hashed_perm_user) {
		$hashedUser = $hashed_perm_user;
		$user = $perm_user;
	***REMOVED***else {
		$hashedUser = myHash($user);
	***REMOVED***

	//update user data into db
	$query = mysqli_query($con, "
	UPDATE `user` 
	SET user = '$hashedUser', wantedMins = '$wantedMins', created = NOW()".$addedSQL."
	WHERE UUID = '".myHash($UUID)."';
	");

	$bandwidth_left = getBandwidthLeft($con, myHash($UUID));
	 
	if(!$query){
		die("0"); 
	***REMOVED***else{
		die($has_expired.$user.','.$bandwidth_left.','.$wantedMins.$addedReturn);
	***REMOVED***
***REMOVED***
***REMOVED***
