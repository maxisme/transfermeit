***REMOVED***
include 'email.php';
include '/var/www/transferme.it/public_html/app/functions.php';

/* @link https://developer.paypal.com/docs/classic/paypal-payments-standard/integration-guide/subscription_billing_cycles/
 */
//custom variables
$account_length = 31; //31 days from payment.
$log_file = "/var/www/transferme.it/log/payments.log"; //31 days from payment.

// Send an empty HTTP 200 OK response to acknowledge receipt of the notification 
header('HTTP/1.1 200 OK'); 
// Assign payment notification values to local variables
$item_name        = $_POST['item_name'];
$item_number      = $_POST['item_number'];
$payment_status   = $_POST['payment_status'];
$payment_amount   = $_POST['mc_gross'];
$payment_currency = $_POST['mc_currency'];
$txn_id           = $_POST['txn_id'];
$receiver_email   = $_POST['receiver_email'];
$payer_email      = $_POST['payer_email'];

if(!$payer_email || !$receiver_email || !$payment_currency || !$payment_amount || !$payment_status){
	die();
***REMOVED***

// Build the required acknowledgement message out of the notification just received
$req = 'cmd=_notify-validate';               // Add 'cmd=_notify-validate' to beginning of the acknowledgement

foreach ($_POST as $key => $value) {         // Loop through the notification NV pairs
	$value = urlencode(stripslashes($value));  // Encode these values
	$req  .= "&$key=$value";                   // Add the NV pairs to the acknowledgement
***REMOVED***

// Set up the acknowledgement request headers
$header = "POST /cgi-bin/webscr HTTP/1.1\r\n";
$header .= "Content-Type: application/x-www-form-urlencoded\r\n";
$header .= "Host:www.paypal.com\r\n";
$header .= "Connection:close\r\n";
$header .= "Content-Length: " . strlen($req) . "\r\n\r\n";

// Open a socket for the acknowledgement request
$fp = fsockopen('tls://www.paypal.com', 443, $errno, $errstr, 30);

// Send the HTTP POST request back to PayPal for validation
fputs($fp, $header . $req);

while (!feof($fp)) {                     // While not EOF
	$res = fgets($fp, 1024);               // Get the acknowledgement response
	//logM($res); 
	if (strpos(trim($res),'VERIFIED') !== false) { 
		if($payment_status != "Completed"){
			$die = 1;
			customLog("INCOMPLETED PAYMENT: $payment_status",true,$log_file);
		***REMOVED***
		
		if($receiver_email != "info@transferme.it"){
			$die = 1;
			customLog("WRONG EMAIL: $receiver_email",true,$log_file);
		***REMOVED***
		
		if($payment_currency != "GBP") { //CHANGE GBP
			$die = 1;
			customLog("WRONG CURRENCY: $payment_currency", true, $log_file);
		***REMOVED***
		
		if($payment_amount % 0.5 == 0){
			$die = 1;
			customLog("$payer_email -> Payed wrong ammount: $payment_amount ".$_POST['mc_fee']." ".$_POST['mc_gross1'],true,$log_file);
		***REMOVED***
		
		if($die == 1){
			sendMail("info@transferme.it", "Transfer Me It", $payer_email, "Unfortunately there has been an error with your PayPal transaction. Please get in contact with us!");
			customLog("FAILED", true, $log_file);
			fclose($fp); 
			die();
		***REMOVED***else{
			$startDate = date("Y-m-d H:i:s");
			//connect to database
			$con = connect();
			
			//check if payee already exists
			$exists = mysqli_query($con, "
				SELECT * FROM `pro`
				WHERE email = '".$payer_email."'
				ORDER BY 
			");
			
			if(mysqli_num_rows($exists) > 0){
				//received a payment from email before
				customLog("Payee already exists.", true, $log_file);

				//update database with another month until expired account
				//get current limit
				while ($row = mysqli_fetch_array($exists)){
					$expiryDate = date("Y-m-d H:i:s", strtotime($row['expiryDate']." + $account_length days"));
					$startDate = $row['expiryDate'];
				***REMOVED***
				
				$updateQuery = mysqli_query($con, "
					UPDATE `pro`
					SET expiryDate = '".$expiryDate."', credit = '".$payment_amount."'
					WHERE userEmail = '".$payer_email."'
				");
				
				if($updateQuery){
					logM("updated payment for 1 month: $payer_email");  
					sendMail("info@transferme.it", "Transfer Me It", $payer_email, "Successfull Payment","Subscription payed for the next month for the account registered with your email. Expires: ".$expiryDate);
				***REMOVED***else{
					logM("failed to update payment for 1 month: $payer_email");  
					
					sendMail("info@transferme.it", "Transfer Me It", "info@transferme.it", "FAILED PAYMENT UPDATE", "UPDATE `pro`
					SET expiryDate = expiryDate + INTERVAL $account_length DAY, credit = '$payment_amount'
					WHERE userEmail = '$payer_email'");
					die();
				***REMOVED***
			***REMOVED***else{
				//user does not exist
				logM("user does not exist");
				//generate unique code for user to enter
				$code = generateRandomString(100);
				
				$query = mysqli_query($con, "
				INSERT INTO `pro` (code, credit, userEmail, expiryDate)
				VALUES ('".$code."', '".$payment_amount."', '".$payer_email."', '".$expiryDate."');
				");
				
				if($query){
					logM("created new user: $payer_email");  
					sendMail("info@transferme.it", "Transfer Me It", $payer_email, "Successfull Payment","Thank you for your payment to transferme.it!<br> To apply your new capabilites to Transfer Me It: Open the app > Options... > Enter Registration Key. And enter the key below:<br><br><strong>$randString</strong>");
				***REMOVED***else{
					logM("failed to create new user INSERT INTO `pro` (code, credit, userEmail, expiryDate)
				VALUES ('".$randString."', '".$payment_amount."', '".$payer_email."', '".$expiryDate."');");
				 
					sendMail("info@transferme.it", "Transfer Me It", "info@transferme.it", "FAILED PAYMENT", "INSERT INTO `pro` (code, credit, userEmail, expiryDate)
				VALUES ('".$randString."', '".$payment_amount."', '".$payer_email."', NOW() + INTERVAL $account_length DAY);");
				***REMOVED***
			***REMOVED***
			$query = mysqli_query($con, "
			INSERT INTO `pro` (code, credit, email, created, expiryDate)
			VALUES ('".$code."', '".$payment_amount."', '".$payer_email."', '".$expiryDate."');
			");
		***REMOVED***
	***REMOVED***
***REMOVED***

fclose($fp);


sendMail("info@transferme.it", "Transfer Me It", "info@transferme.it", "NEW PAYMENT", file_get_contents('/var/www/appStuff/deleteLog.txt')); 
  
***REMOVED*** 