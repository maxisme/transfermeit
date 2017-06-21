<?php
session_start();
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <!-- meta -->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <title>Transfer Me It</title>
    <meta name="keywords"
          content="transfer me it, transfermeit, file, send, transfer, me, it, transfer, file transfer, send files, mac, osx, mac to mac">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>
    <!-- Google Fonts -->
    <link href='https://fonts.googleapis.com/css?family=Muli' rel='stylesheet' type='text/css'>
    <link href='https://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet' type='text/css'>
    <link href="https://fonts.googleapis.com/css?family=Heebo:300" rel="stylesheet">
    <!-- jquery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <!-- css -->
    <link rel="stylesheet" type="text/css" href="https://maxis.me/template/css/style.css"/>
    <link href="https://fonts.googleapis.com/css?family=Heebo:300" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="css/style.css"/>
    <!-- scripts -->
    <script type="text/javascript" src="https://maxis.me/template/scripts/jquery.easing.min.js"></script>
    <script type="text/javascript" src="https://maxis.me/template/scripts/scrolling-nav.js"></script>
    <script type="text/javascript" src="https://maxis.me/template/scripts/script.js"></script>
    <script type="text/javascript" src="scripts/script.js"></script>

    <script type="text/javascript" src="https://cdn.jsdelivr.net/vivus/0.2.3/vivus.min.js"></script>
    <script src="https://js.braintreegateway.com/v2/braintree.js"></script>

    <style>
        .lineText {
            -webkit-text-fill-color: transparent;
            -webkit-text-stroke-width: 1px;
            -webkit-text-stroke-color: #EFEFEF;
        }

        #price {
            -webkit-text-fill-color: #F87B87;
        }
    </style>
</head>

<body>
<!-- home page -->
<page id="home">
    <a class="page-scroll" href="#home"><img class="shadowed homeButton" src="images/icon.svg" height="50"/></a>
    <div align="center">
        <div id="my-div"><img class="mainIcon" style="fill: #fff" src="images/logo.png" height="400"/>
        </div>
        <h1 style="letter-spacing:2px">Transfer Me It</h1>
        <div id="navMenu">
            <a class="page-scroll" href="#howitworks">How It Works</a> | <a class="page-scroll" href="#security">Security</a>
            | <a class="page-scroll" href="#credit">Credit</a> | <a class="page-scroll" href="#contact">Contact</a>
        </div>
        <br/><br/><br/><br/>
        <span id="download">
				<a id="down" href="download.php">download</a>
				<br/><br/>
	<span style="font-size:10px">Transfer Me It is in its BETA stage so be prepared to keep updating the app.</span>
    </div>
    <p>&nbsp;</p>
</page>

<!-- howitworks -->
<page id="howitworks">
    <h2>How It Works</h2>
    <span class='info'>
            <strong>Transfer Me It</strong> - a simple and secure file transfer application between Macs. <br/><br/>
            Have you ever wanted to be able to send a file seemlesly to a friend, client or colleague... Of course you have!<br>
            We have all been there, your friend in Paris wants that photo you took of them, your client in Hong Kong wants an up to date proposal, your colleague needs the new promo video.<br/>
            You want this to be done fast, hassle free and without worrying about outsiders who may be looking at your private file.<br>
            With <strong>Transfer Me It</strong> all you need is to download the very light weight application, to sit quietly on your menubar and you are ready to go! There is no long convoluted sign up process.
    </span>


    <h3>How to send a file?</h3>
    <p class='info'>
		To send a file click 'Send File' from Transfer Me It's drop down menu, pick the file you want to send, enter your friends code and voila.
	</p>

    <p>
        <img src="images/info/SendFile.png" width="30%"/>
        <!--
<img class="shadowed" src="infoImages/EnterFriendsCode.png" height="150px"/>
-->
    </p>
    <h3>How to download a file?</h3>
    <p class='info'>
            Once your friend has sent the file you’ll receive a desktop notification, alerting you of an incoming file. Click 'yes' when asked "would you like to download '...'?" and choose where you want the file to be saved.
	</p>

    <p>
        <img src="images/info/incomingFile" width="30%"/>
    </p>
    <h3>What is the "Create A Code for > x minutes" option?</h3>
    <p class='info'>
By default transfer me it will create a 10 minute <strong>code</strong> for you. This will give you both a unique code that lasts only 10 minutes and will store your (inactive) encrypted file on the server for a maximum of 10 (inactive) minutes (files are immediately deleted once your friend has downloaded the file). Depending on your <a href="#credit">credit</a> you can choose up to 1 hour.
	</p>
    <p>&nbsp;</p>
</page>

<!-- Security -->
<page id="security">
    <h2>security</h2>
    <span class='info'>
            <p class='info'>
			    We do not take or want any of your files!
            </p>
            <p class='info'>
                Each time you send a file it is encrypted using a unique 256 character key locally with <a
                        target="_blank" href="https://github.com/RNCryptor/RNCryptor">AES encryption</a> before being uploaded and sent to your friend. Your friend will receive part of this key through an impenetrable socket and the other part when they have authenticated the download - the file will then be purged from the server and decrypted locally – this means that even we can't decrypt the file!
            </p>
            <p class='info'>
			    All connections between your computer and our server are with TLS encryption.
            </p>
            <p class='info'>
			    And if that doesn’t make you think the app is secure and private enough - after the file you’re sending has been downloaded, it is deleted from the server and then overwritten with lots of '0's (to protect against any sort of recovery of the storage).
            </p>
            <p class='info'>
                You also don't need to take our word for it. Transfer Me It is <a target="_blank"
                                                                                  href="https://github.com/maxisme/transfermeit">open source</a>!
            </p>
		</span>
    <p>
        <br/><br/>
    <div align="center">
        <img src="images/lock.png" height="150px"/>
    </div>
    <div id="lock"></div>
    </p>
    <p>&nbsp;</p>
</page>

<!-- pro -->
<page id="credit">
    <h2>credit</h2>
    <div id="proInfo" align="center">
        <p class='info' style="font-size:10px; text-transform:none;">Move the slider to decide on how much you want to pay for Transfer Me It.</p>
		<p>
		    <input style="width: 60% !important;" width="50%" id="credit_slider" type="range" min="1" max="10" step="1" value="5">       </p>
        <p>
            £<input type="number" min="0" max="50" id="credit_val"/>
        </p>
        <p class='info' style="font-size:10px;">Will get you</p>
        <div class="credit_items">
            <p>Some ❤️️!</p>
            <span id="storageTime"></span>
            <span id="file_size"></span>
            <span id="bandwidth"></span>
            <span id="permCode"></span>
            <span id="customCode"></span>
        </div>
        <p>
		    <span id="purchaseButton"><input class='lineText buyNow' type="submit" value='BUY NOW!' disabled></span>
        </p>
        <p class="info">
		    After making your super secure PayPal payment, you will receive an email (to your PayPal email address) with a Registration Key. You can then enter that key on the App, to activate your Pro account.
        </p>
    </div>
    <p>&nbsp;</p>
</page>

<!-- Contact -->
<page id="contact">
    <h2>contact</h2>
    <span class='info'>
        <span id="contactForm">
        <div align="center">
        <?php
        if ($_SESSION["error"] > 0 && $_SESSION["error"] < 5) {
            echo "<span class='email_note' style='color:#6C0207'>";
            if ($_SESSION["error"] == 1) {
                echo "Error: No Email Address";
            } else if ($_SESSION["error"] == 2) {
                echo "Error: No Name";
            } else if ($_SESSION["error"] == 3) {
                echo "Error: No Message";
            } else if ($_SESSION["error"] == 4) {
                echo "Error: Invalid Email";
            }
            echo "</span>
		";
            $_SESSION["error"] = NULL;
        } else if ($_SESSION["success"] == 1) {
            echo "<span class='email_note' style='color:#2A682E'>Success! We will get back to you as soon as possible!</span>";
            $_SESSION["success"] = NULL;
        } ?>
		</div>
		<form action="backend/submitContact.php" method="post">
			Name<br/>
			<input name="name" type="text" required><br/><br/> Email
			<br/>
			<input name="email" type="email" required><br/><br/> Message
			<br/>
			<textarea style="resize: vertical;" name="message" required="required" rows="5"></textarea><br/><br/>
            <!--<div class="g-recaptcha" data-theme="dark" data-sitekey="6LfzGhITAAAAANBon7DeBgx2TSfch3i85zmxJOcw"></div><br /> -->
			<input id="sendEmail" value="Send" type="submit"/>
		</form>
		</span>
</page>

<?php
if ($_SESSION["payed"] == "yes") {
    $_SESSION["payed"] = "" ?>
    <page id="payed">
        <div align="center">
            <h2>Successfull Payment!</h2>
            <span class='info'>
                Thank you very much for your subscription to Transfer Me It! 
                <br/>
                <br/>
                Please check your emails for your <strong>pro Registration Key</strong>!
            </span>

            <br/><br/>
            <img src="images/tick.png" height="150"/>
        </div>
    </page>
<?php } ?>

<!-- weird element to add shaddow to images... don't ask -->
<svg height="0" xmlns="http://www.w3.org/2000/svg">
    <filter id="drop-shadow">
        <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
        <feOffset dx="0" dy="0" result="offsetblur"/>
        <feFlood flood-color="rgba(0,0,0,0.5)"/>
        <feComposite in2="offsetblur" operator="in"/>
        <feMerge>
            <feMergeNode/>
            <feMergeNode in="SourceGraphic"/>
        </feMerge>
    </filter>
</body>

</html>