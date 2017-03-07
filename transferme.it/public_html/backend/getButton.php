<?php

error_reporting(E_ALL);
ini_set("display_errors", 1);


include_once 'createPaypalButton.php';

if(!isset($_GET['credit'])){
	die();
}
$credit = $_GET['credit'];

if(is_int($credit) && $credit <= 20){
	echo createButton("Transfer Me It $credit"."GB account", $credit);
} 
?>