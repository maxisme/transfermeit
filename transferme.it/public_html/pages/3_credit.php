<div align="center">
    <i>Move the slider to decide on how much credit you want for Transfer Me It.</i>
    <h4 class='info error strong'>
        £<span id="price" class="">5.00</span>
    </h4>
    <p>
        <input id="credit_slider" type="range" min="0.5" max="20" step="0.5" value="5"/>
    </p>
    <div align="center" class="credit_items">
        <ul>
            <li id="has_custom_code"></li>
            <li id="file_size"></li>
            <li id="bandwidth"></li>
        </ul>
    </div>
    <p>
    <div id="purchase_button"><button class='material-icons' disabled>payment</button></div>
    </p>
    <p style="font-size: 0.8rem" class="info">
        After making your super secure PayPal payment, you will receive an email (to your PayPal email address) with a Registration Key. You can then enter that key on the App, to activate your Pro account.<br>
        * As your bandwidth credit drops so does the single upload file size limit.<br>
        ** A permanent code and a custom code <strong>does not</strong> get removed according to your credit. Once you have bought a <strong>single</strong> payment your code will be permanent forever with the option to remove.
    </p>
</div>

<!-- JAVASCRIPT -->
<script>
    /* global variables */
    var fetchingButton = false;
    var lastCredit = null;

    /* initialise elements */
    var slider = $('#credit_slider');
    var custom_perm_code = $('#has_custom_code');
    var file_size = $("#file_size");
    var bandwidth = $("#bandwidth");
    var price_label = $("#price");

    function changeCredit(credit){
        /* TODO: SET BY BACKEND */
        var min_perm_code = 5;
        var min_custom_code = 10;
        var max_credit = 20;
        var min_credit = 0.5;

        if(credit > max_credit) credit = max_credit;
        if(credit < min_credit) credit = min_credit;

        price_label.html(credit);

        // remove content from dynamic tags
        custom_perm_code.html("");
        file_size.html("");
        bandwidth.html("");

        //single file
        file_size.html("Upload a file of up to <span class='highlight'>"+credit+"GB</span> in size*");

        //bandwidth
        bandwidth.html(credit+"GB of bandwidth to upload files with*");

        if(credit >= min_perm_code){
			//perm code
        	custom_perm_code.html("A <strong>permanent</strong> user code.**");
		}else if(credit >= min_custom_code){
			//custom code
			custom_perm_code.css("display");
			custom_perm_code.html("A <strong>custom</strong> user code.**");
        }

		Materialize.showStaggeredList('#staggered-test')

        if (lastCredit !== credit && !fetchingButton) {
            $.ajax({
                url: 'backend/getButton.php',
                type: 'GET',
                data: "credit="+credit,
                beforeSend: function () {
                    $("#purchase_button input").prop('disabled', true); // prevent the user from pressing purchase while fetching the dynamic button.
                    fetchingButton = true;
                },
                success: function (data) {
                    console.log("data: " + data);
                    //var html_button = data.replace('type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_subscribe_LG.gif"', "class='lineText buyNow' type='submit' value='BUY NOW!'");
                    $("#purchase_button input").prop('disabled', false); // now allow the user to click the purchase button
                    $("#purchase_button").html(data);
                    lastCredit = credit;
                    fetchingButton = false;
                }
            });
        }
    }

    $(document).ready(function () {
        changeCredit(5.0); // default £5 credit

        //on manual edit
        $('#credit_val').keyup(function () {
            changeCredit($(this).val());
        });

        //on slider
        slider.mousemove(function () {
            if(!$('#credit_val').is(":focus")) {
                changeCredit($(this).val());
            }
        });
    });
</script>

<!-- echo -n "$(system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }')" | shasum -a 256 -->