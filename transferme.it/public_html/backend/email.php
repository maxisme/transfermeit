<?php
require 'PHPMailer/PHPMailerAutoload.php';

function sendMail($from, $name, $subj, $msg){
    $email_user = trim(file_get_contents("/var/www/transferme.it/email.user"));
    $email_pass = trim(file_get_contents("/var/www/transferme.it/email.pass"));

	$mail = new PHPMailer;
	
	$mail->isSMTP();                                      // Set mailer to use SMTP
	$mail->Host = 'mail.maxemails.info';  // Specify main and backup SMTP servers
	$mail->SMTPAuth = true;                               // Enable SMTP authentication
	$mail->Username = $email_user;                 // SMTP username
	$mail->Password = $email_pass;                           // SMTP password
	$mail->SMTPSecure = 'TLS';                            // Enable TLS encryption, `ssl` also accepted
	$mail->Port = 587;                                    // TCP port to connect to
	
	$mail->From = $from;
	$mail->FromName = $name;
	$mail->addAddress('max@transferme.it');
	
	$mail->Subject = $subj;
	$mail->Body    = $msg;
	
	$mail->SMTPOptions = array(
		'ssl' => array(
			'verify_peer' => false,
			'verify_peer_name' => false,
			'allow_self_signed' => true
		)
	);
	
	if(!$mail->send()) {
		echo 'Message could not be sent.';
		echo 'Mailer Error: ' . $mail->ErrorInfo;
	} else {
		$_SESSION['error'] = 0;
		die(header("Location: /contact"));
	}
}
?>