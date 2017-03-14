<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require 'functions.php';

//connect to database
$con = connect();

//initial variables
$remove_perm_code = false;
$allowed_custom_code = false;
//POST variables
if (isset($_POST['customCode'])) {
    $customCode = trim(mysqli_real_escape_string($con, $_POST['customCode']));
    if ($customCode == "0") {
        $remove_perm_code = true;
    }
}
$UUID = mysqli_real_escape_string($con, $_POST['UUID']);
$UUIDKey = mysqli_real_escape_string($con, $_POST['UUIDKey']);

if (empty($UUIDKey) || !UUIDRegistered($con, $UUID, $UUIDKey)) {
    die(json_encode(array("status" => "Invalid User")));
}

$query = mysqli_query($con, "
SELECT *
FROM `pro`
WHERE UUID = '" . myHash($UUID) . "'
");

while ($row = mysqli_fetch_array($query)) {
    if (userTier(myHash($UUID)) == 2) {
        //user is allowed a CUSTOM CODE
        if (userTier(myHash($UUID)) == 3) {
            $allowed_custom_code = true;
        }
        $pro_code = $row['code'];
    }
}

if (isset($pro_code)) {
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