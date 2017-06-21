<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect();

$remove_perm_code = false;
//POST variables
if (isset($_POST['customCode'])) {
    $customCode = trim(mysqli_real_escape_string($con, $_POST['customCode']));
    if (empty($customCode)) {
        $remove_perm_code = true;
    }
}
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);

//validation
if (!UUIDRegistered($con, $UUID, $UUIDKey)) {
    die(json_encode(array("status" => "Invalid User")));
}

$tier = userTier(myHash($UUID));
if ($tier >= 2) {
    if ($remove_perm_code) {
        //stop using perm user code
        if (!mysqli_query($con, "UPDATE `pro`
        SET perm_user = NULL
        WHERE code = '$pro_code'")
        ) {
            dieStatus("Failed removing permanent code");
        } else {
            dieStatus("1");
        }
    } else {
        if (!$allowed_custom_code || empty($customCode)) {
            //create a random new perm code
            $customCode = genUser();
        } else if (!validUserFormat($customCode)) {
            dieStatus("Custom code must be 7 characters and only contain letters and numbers");
        }

        if (!mysqli_query($con, "UPDATE `pro`
        SET perm_user = '" . myHash($customCode) . "'
        WHERE code = '$pro_code'")
        ) {
            dieStatus("Custom code may already be in use");
        }else{
            dieStatus(array("code" => "$customCode"));
        }
    }
}

dieStatus("Invalid User 2");
?>