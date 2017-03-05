<?php

require '/var/www/transferme.it/public_html/app/functions.php';
$con = connect();
$user = "*F26B2E8A84FBB5CA12177C67C2E80119DA0702CB";

echo megaToBytes(3000)."<br>";
echo getUsedBandwidth($con, $user);
$bandwidth_left = getBandwidthLeft($con, $user);
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

echo myHash(" ");