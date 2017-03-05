***REMOVED***
include_once 'createPaypalButton.php';

if(!$_GET['amt']){
	die();
***REMOVED***

if($_GET['amt'] % 0.5 == 0){ //50p intervals
	$button = createButton("Transfer Me It ".round($_GET['amt'], 1)."GB account", $_GET['amt']);
	echo $button;
***REMOVED*** 
***REMOVED***