<?php 
session_start();
$_SESSION["payed"] = "yes";
exit(header("Location: /#payed"));
?>