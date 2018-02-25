<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

function dieStatus($status){
    $status_arr = $status;
    if(!is_array($status)){
        $status_arr = array("status" => "$status");
    }
    die(json_encode($status_arr));
}

//connect to database
$con = connect();

//POST variables
$customCode = san($con, $_POST['customCode']);
$currentCode = san($con, $_POST['currentPermCode']);
$UUID = san($con, $_POST['UUID']);
$UUIDKey = san($con, $_POST['UUIDKey']);

//validation
if (!UUIDRegistered($con, $UUID, $UUIDKey)) dieStatus("Invalid User");

$tier = userTier(myHash($UUID));
if ($tier >= 2) {
    if(!empty($currentCode) && getUserPermCode($con, $UUID, $currentCode)){
        // delete perm code TOGGLE
        $delete_perm_code = mysqli_query($con, "
        UPDATE `pro`
        SET `permUserCode` = NULL
        WHERE UUID = '".myHash($UUID)."';
        ");
        if($delete_perm_code) dieStatus("removed");
        dieStatus("error removing perm user code");
    }else{
        // create perm code TOGGLE
        if (empty($customCode) || $tier == 2) {
            //create a random new perm code
            $customCode = genUser($con);
        }else if (!validUserFormat($customCode)) {
            dieStatus("Custom code must be 7 characters and only contain letters and numbers");
        }

        if(userCodeAvailable($con, $customCode)){
            // this will update permUserCode for all the pro keys the user has
            if (!mysqli_query($con, "UPDATE `pro`
        SET permUserCode = '" . myHash($customCode) . "'
        WHERE UUID = '".myHash($UUID)."'")) {
                dieStatus("Not able to set permanent code.");
            } else {
                die(json_encode(array("perm_user_code" => "$customCode")));
            }
        }else{
            dieStatus("Code already taken!");
        }
    }
}else{
    dieStatus("You are not eligible for a permanent or custom code!");
}
?>