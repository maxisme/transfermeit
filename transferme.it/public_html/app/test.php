<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

require '/var/www/transferme.it/public_html/app/functions.php';
$con = connect();
$user = "ba1d634d96a0d55017716f763ea71ce7fdabd57d1f1368262d186c435a768aac";

echo megaToBytes(3000)."<br>";
echo "1.".getCredit($con, $user)."<br>";
echo getUsedBandwidth($con, $user, true)."<br>";
echo $bandwidth_left = getBandwidthLeft($con, $user);
echo "<p>Bandwidth Left ".bytesToMega($bandwidth_left)." MB</p>";
echo "<p>Max Upload ".bytesToMega(getMaxUploadSize($con,$user))." MB";

//--------------------------
$test_MB = 4000;

echo "<h2>Test with $test_MB MB left</h2>";
$bandwidth_left = megaToBytes($test_MB);

echo "<p>Bandwidth Left $test_MB MB</p>";

echo "<p>Max Upload ".bytesToMega(maxUploadSize($bandwidth_left))." MB</p>";

$credit = bandwidthToCredit($bandwidth_left);

echo "<p>Credit £$credit</p>";

echo bytesToMega(creditToBandwidth(0))."<br>";
echo bytesToMega(creditToBandwidth(0.5))."<br>";
echo bytesToMega(creditToBandwidth(1))."<br>";

echo bytesToMega(2147483647);

echo myHash(" ");

require '/var/www/transferme.it/public_html/backend/createPaypalButton.php';

$arr = array();
$arr['user'] = "123";
$arr['secure'] = "1";
print_r($arr);

if (!fsockopen('127.0.0.1', 48341)) {
    echo "closed";
}else{
    echo "open";
}
//for($i=1; $i <= 20; $i++){
//    //subscribe
//    echo $html_button = createButton("£$i credit", $i);
//    echo "<br><br>";
//    $html = base64_encode($html_button);
//    mysqli_query($con,"INSERT INTO `paypal_buttons`
//    (name,price,html,type)
//    VALUES
//    ('£$i credit','$i','$html','buyitnow')");
//}

echo myHash("XJFWXPZ");

echo "<br>";

echo myHash("KII2B5E");

echo "<br>".bytesToMega(2443181424);