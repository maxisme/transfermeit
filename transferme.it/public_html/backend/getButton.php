<?php

error_reporting(E_ALL);
ini_set("display_errors", 1);

require '../app/functions.php';
require 'createPaypalButton.php';

if(!isset($_GET['credit'])){
	die('1');
}

$credit = $_GET['credit'];

if(is_int((int)$credit) && $credit <= 20){
//    $con = connect();
//    $get_button = mysqli_query($con,"SELECT `html`
//    FROM `paypal_buttons`
//    WHERE price='$credit'");

//    while ($row = mysqli_fetch_array($get_button)){
//        die(base64_decode($row['html']));
//    }
    die(createButton("TMI Credit", $credit));
}else{
    echo "error";
}
?>