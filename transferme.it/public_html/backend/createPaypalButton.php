<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

function get_string_between($string, $start, $end){
    $string = " ".$string;
    $ini = strpos($string,$start);
    if ($ini == 0) return "";
    $ini += strlen($start);
    $len = strpos($string,$end,$ini) - $ini;
    return substr($string,$ini,$len);
}

function createButton($name, $price, $subscribe = false){
    $pass = trim(file_get_contents("/var/www/transferme.it/paypal.pass"));
    $sig = trim(file_get_contents("/var/www/transferme.it/paypal.sig"));
	//create array of button info
    $payData = array(
        "METHOD" => "BMCreateButton",
        "VERSION" => "65.2",
        "USER" => "info_api1.transferme.it",
        "PWD" => "$pass",
        "SIGNATURE" => "$sig",
        "BUTTONCODE" => "ENCRYPTED",
        "BUTTONSUBTYPE" => "SERVICES",
        "BUTTONCOUNTRY" => "GB",
        "BUTTONIMAGE" => "reg",
        "L_BUTTONVAR1" => "return=https://transferme.it/#payed",
        "L_BUTTONVAR2" => "item_name=".$name,
        "L_BUTTONVAR3" => "notify_url=https://transferme.it/backend/paypalNotify.php",
        "L_BUTTONVAR4" => "currency_code=GBP",
        "L_BUTTONVAR5" => "no_shipping=1"
    );
    if($subscribe){
        //make a subscribe button
        $extraData = array(
            "PAYPERIOD" => "MONTH",
            "BUTTONTYPE" => "SUBSCRIBE",
            "L_BUTTONVAR6" => "a3=".$price,
            "L_BUTTONVAR7" => "p3=1", 	// every (2 would mean every 2) ...
            "L_BUTTONVAR8" => "t3=M",	// Months
            "L_BUTTONVAR9" => "src=1"
        );
    }else{
        //single buy now button
        $extraData = array(
            "BUTTONTYPE" => "BUYNOW",
            "L_BUTTONVAR6" => "amount=".$price
        );
    }

    $payData += $extraData;

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($curl, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);
	//post data to paypal
	curl_setopt($curl, CURLOPT_URL, 'https://api-3t.paypal.com/nvp');
    curl_setopt($curl,CURLOPT_POST, count($payData));
    curl_setopt($curl,CURLOPT_POSTFIELDS, http_build_query($payData));
	$nvpPayReturn = curl_exec($curl);
	curl_close($curl);

	//return only the html
	$nvpPayReturn = urldecode(get_string_between($nvpPayReturn,"WEBSITECODE=","&EMAILLINK="));
	$button = "<form".get_string_between($nvpPayReturn,"<form","-----END PKCS7-----");
    $button .= "-----END PKCS7-----\"><button type='submit' class='material-icons'><i class=\"fab fa-cc-paypal\"></i></button>";
	return $button;
}
?>