***REMOVED***
***REMOVED***
***REMOVED***

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
	***REMOVED***else if(!validUserFormat($customCode)){
		die('2');
	***REMOVED***
***REMOVED***
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$pro_code = mysqli_real_escape_string($con, $_POST['pro_code']);

if(strlen($pro_code) != 100 || hasSpecialChars($pro_code)){
	die("3");
***REMOVED***

if (!UUIDRegistered($con, $UUID)) {
	die('4');
***REMOVED***

if(!isProUser($con, $pro_code, $UUID)){
	die("5");
***REMOVED***

$query = mysqli_query($con, "
SELECT *
FROM `pro`
WHERE code = '$pro_code'
");

while ($row = mysqli_fetch_array($query)){
	if($row['maxLimitMB'] >= $custom_pro_mb){
		//user is allowed a CUSTOM CODE
		$allowed_custom_code = true;
	***REMOVED***
***REMOVED***

if($remove_perm_code){
	//stop using perm user code
	if(!mysqli_query($con,"UPDATE `pro`
	SET perm_user = NULL
	WHERE code = '$pro_code'")){
		//failed to update pro code
		die("5");
	***REMOVED***else{
		die("1");
	***REMOVED***
***REMOVED***else{
	if(!$allowed_custom_code || !isset($_POST['pro_code'])){
		$customCode = genUser();
	***REMOVED***

	if(!mysqli_query($con,"UPDATE `pro`
	SET perm_user = '".myHash($customCode)."'
	WHERE code = '$pro_code'")){
		die("6");
	***REMOVED***
***REMOVED***

echo "0$customCode";

***REMOVED***