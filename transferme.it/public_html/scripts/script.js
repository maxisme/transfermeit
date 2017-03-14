var lastCredit = -1;
var fetchingButton = false;

function changeCredit(credit){
    if(credit > 20) {
        credit = 20;
    }

	$('#credit_val').val(credit);
	$('#credit_slider').val(credit);

    if(credit < 1){
        credit = 1;
    }

    $("#permCode").html("");
    $("#customCode").html("");
    $("#file_size").html("");
    $("#bandwidth").html("");

    //custom code
    if(credit >= 10){
        $("#customCode").html("<p>A custom user code.</p>");
    }

    //perm code
    if(credit >= 5){
        $("#permCode").html("<p>A permanent user code.</p>");
    }

    //single file
    $("#file_size").html("<p>A <span class='highlight'>"+credit+"GB</span> file upload limit.</p>");

    //bandwidth
    $("#bandwidth").html("<p><span class='highlight'>"+credit+"GB</span> bandwidth to upload files with.</p>");

    if (lastCredit != credit && !fetchingButton) {
        $.ajax({
            url: 'backend/getButton.php',
            type: 'GET',
            data: "credit="+credit,
            beforeSend: function () {
                console.log("bef");
                $("#purchaseButton input").prop('disabled', true);
                fetchingButton = true;
            },
            success: function (data) {
                console.log("data: " + data);
                //var html_button = data.replace('type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_subscribe_LG.gif"', "class='lineText buyNow' type='submit' value='BUY NOW!'");
                $("#purchaseButton input").prop('disabled', false);
                $("#purchaseButton").html(data);
                lastAmt = credit;
                fetchingButton = false;
            }
        });
    }
}

$(document).ready(function () {
    changeCredit(5.0);

    //on manual edit
    $('#credit_val').keyup(function () {
        changeCredit($(this).val());
    });

    //on slider
    $('#credit_slider').mousemove(function () {
        if(!$('#credit_val').is(":focus")) {
            changeCredit($(this).val());
        }
    });
});
