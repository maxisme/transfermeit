<?php
//runs from cron.
(PHP_SAPI !== 'cli' || isset($_SERVER['HTTP_USER_AGENT'])) && die('cli only');

error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect(); 

//get out of date uploads
$out_of_date_query= mysqli_query($con,"
SELECT 
    `upload`.id as id,
	`upload`.path as path, 
	`upload`.`toUUID` as toUUID,
	`upload`.`fromUUID` as fromUUID
FROM `upload`
JOIN `user`
ON `upload`.`fromUUID` = `user`.`UUID`
WHERE `upload`.started + interval `user`.`wantedMins` minute <= NOW()
AND (upload.updated IS NULL OR upload.updated + interval 1 minute <= NOW())
AND `upload`.finished IS NULL
");

$deleted=0;
while ($row = mysqli_fetch_array($out_of_date_query)){
	if(!deleteUpload($con, $row['toUUID'], $row['fromUUID'], $row['path'], true)){
	    echo "ERROR with ".$row['id'];
    }else{
        $deleted++;
    }
}
echo "Deleted $deleted rows";
?>