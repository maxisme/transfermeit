<?php

error_reporting(E_ALL);
ini_set("display_errors", 1);

require '../app/functions.php';
require 'createPaypalButton.php';

if(!isset($_GET['credit']) || !isset($_GET['type'])){
	die('1');
}

$credit = $_GET['credit'];
$type = $_GET['type'];

if($type != "subscribe" && $type != "buyitnow"){
    die("2 '$type'");
}

if(is_int((int)$credit) && $credit <= 20){
    $con = connect();
    $get_button = mysqli_query($con,"SELECT `html`
    FROM `paypal_buttons`
    WHERE price='$credit'
    AND type = '$type'");

    while ($row = mysqli_fetch_array($get_button)){
        die(base64_decode($row['html']));
    }
}else{
    echo "error";
}
?>