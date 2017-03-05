$(document).ready(function () {
	// ----- scrolling -----
    $('a.page-scroll').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        ***REMOVED***, 1500, 'easeInOutExpo');
        event.preventDefault();
    ***REMOVED***);
	
	// ----- CLOUD ----- 
	var isHiding;
	if ($(document).scrollTop() > $("#home").height()) {
		isHiding = false;
	***REMOVED*** else {
		isHiding = true;
		$(".homeButton").css("opacity", 0);
		$(".homeButton").css("right", "-5px");
	***REMOVED***
	$(document).scroll(function () {
		if ($(document).scrollTop() > $("#home").height()) {
			console.log("showing");
			if (isHiding == true) {
				isHiding = false;
				$(".homeButton").animate({
					opacity: 1,
					right: "10px"
				***REMOVED***, 500);
			***REMOVED***
		***REMOVED*** else {
			console.log("hiding");
			if (isHiding == false) {
				isHiding = true;
				$(".homeButton").animate({
					opacity: 0,
					right: "-5px"
				***REMOVED***, 500);
			***REMOVED***
		***REMOVED***
	***REMOVED***);

	//prevent any other user than mac osx
	if (navigator.userAgent.indexOf('Mac OS X') == -1) {
		$("#down").css("text-decoration", "line-through");
		$("#download").append("<br /><br /><span id='info'>Unfortunately this app is only for OSX</span>");
	***REMOVED***
	console.log('Your OS is: ' + navigator.appVersion);

	$("#purchaseButton input").prop('disabled', true);

	$.get("getButton.php", {
		amt: '1.00'
	***REMOVED***, function (data) {
		var newData = data.replace('type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_subscribe_LG.gif"', "class='lineText buyNow' type='submit' value='BUY NOW!'");

		$("#purchaseButton input").prop('disabled', false);
		$("#purchaseButton").html(newData);
		$("#purchaseButton").show();
	***REMOVED***);
	var lastAmt = 1.0;
	var issending = 0;
	var amt;

	$('#discount_credits').on("change mousemove", function () {
		amt = $('#discount_credits').val();
		$("#name").html("");
		if (amt == "50") {
			$("#name").html("<li>A custom User ID</li>");
		***REMOVED*** else if (parseInt(amt) > 9 && parseInt(amt) < 20) {
			$("#storageTime").html("<li>Up to <span class='lineText'>30 mins</span> of file storage</li>");
		***REMOVED*** else if (parseInt(amt) > 19) {
			$("#storageTime").html("<li>Up to <span class='lineText'>1 hour</span> of file storage</li>");
		***REMOVED*** else {
			$("#storageTime").html("");
		***REMOVED***

		if (amt.charAt(1)) {
			amt = amt.charAt(0) + "." + amt.charAt(1);
			$("#storageInfo").html("<li>A permanent User ID</li>");
		***REMOVED*** else {
			amt = "0." + amt.charAt(0);
			$("#storageInfo").html("");
		***REMOVED***

		$("#price").html(amt + "0");
		$("#amt").html("<span class='lineText'>" + amt + "GB</span> of space to upload files with");

		//get paypal button

		$('#discount_credits').on("change", function () {
			console.log("asd");
			if (lastAmt != amt && issending == 0) {
				$.ajax({
					url: 'backend/getButton.php',
					type: 'GET',
					data: "amt=" + amt + "0", 
					beforeSend: function () {
						$("#purchaseButton input").prop('disabled', true);
						issending = 1;
					***REMOVED***,
					success: function (data) {
						var newData = data.replace('type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_subscribe_LG.gif"', "class='lineText buyNow' type='submit' value='BUY NOW!'");
						$("#purchaseButton input").prop('disabled', false);
						$("#purchaseButton").html(newData);
						$("#purchaseButton").show();
						lastAmt = amt;
						console.log("stored:" + lastAmt);
						issending = 0;
					***REMOVED***
				***REMOVED***);
			***REMOVED***
		***REMOVED***);
	***REMOVED***);
***REMOVED***);
