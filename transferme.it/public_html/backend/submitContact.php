<?php
session_start();

//---------------EMAIL------------------

//get variables from form
$from = $_POST['email'];
$msg = $_POST['message'];
$name = $_POST['name'];

//validate input
if(strlen($from) == 0){
	$_SESSION["error"] = 1;
	die(header("Location: /#contact"));
}

if(strlen($name) == 0){
	$_SESSION["error"] = 2;
	die(header("Location: /#contact"));
}

if(strlen($msg) == 0){
	$_SESSION["error"] = 3;
	die(header("Location: /#contact"));
}

//validate email
if (!filter_var($from, FILTER_VALIDATE_EMAIL)) {
	$_SESSION["error"] = 4;
	die(header("Location: /#contact"));
}

require 'PHPMailer/PHPMailerAutoload.php';

$mail = new PHPMailer;

//$mail->SMTPDebug = 2;                               // Enable verbose debug output

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = 'mail.maxemails.info';// Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = 'info@transferme.it';                 // SMTP username
$mail->Password = '5JNlVkeamd2Wgqn5I5xJ';                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
$mail->Port = 587;                                    // TCP port to connect to

$mail->From = $from;
$mail->FromName = $name;
$mail->addAddress('info@transferme.it');

$mail->Subject = "Transfer Me It - Contact form";
$mail->Body    = $msg;

if(!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
	$_SESSION["success"] = 1;
	die(header("Location: /#contact"));
}
?>