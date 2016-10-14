$(function () {
    $("#order_id").focus();

    $("#order_weights_form")
        .bind("ajax:success", function (xhr, data, status) {
            $("#update-container").html(xhr.responseText);
            $('#order_id').val("").focus();
            setupWeighing();
        })
        .bind("ajax:error", function (evt, xhr, status, error) {
            $('#update-container').html(xhr.responseText);
        });
});


var current_packaging_id;

$(document).on('click', '#get_ad_hoc_rates', function () {
    if (check_your_packing_entered()) {
        get_rate_data();
    } else {
        error_dialog('Please check all package dimensions are entered');
    }
});

$(document).on('keydown', '#order_shipping_weight', function (event) {
    if (!matrixShipping && event.keyCode == 13) {
        save_form();
    }
});

function check_your_packing_entered() {
    var ok = true;

    var fields = ['#ad_hoc_packaging_size_depth', '#ad_hoc_packaging_size_length', '#ad_hoc_packaging_size_width'];

    fields.forEach(function (field) {
        if ($(field).val()) {
            if (isNaN($(field).val())) {
                ok = false;
            }
        } else {
            ok = false;
        }
    });

    return ok;
}

function get_dimension_data() {
    return {
        package_height: $('#ad_hoc_packaging_size_depth').val(),
        package_length: $('#ad_hoc_packaging_size_length').val(),
        package_width: $('#ad_hoc_packaging_size_width').val()
    }
}

function reset_ad_hoc_data() {
    $('#ad_hoc_packaging_size_depth').val('');
    $('#ad_hoc_packaging_size_length').val('');
    $('#ad_hoc_packaging_size_width').val('');
}

$(document).on('click', '.packaging_type_btn', function () {


    if (check_weight_entered()) {

        var comp_pack_type_id = $(this).attr('id');
        current_packaging_id = comp_pack_type_id.replace('packaging_type_btn_', '');

        if (current_packaging_id != comp_pack_type_id.replace('packaging_type_btn_', '')) {
            reset_ad_hoc_data();
        }

        if (current_packaging_id == ad_hoc_packaging_id) {
            $('#ad_hoc_packaging_size').show();
            $('#available_shipping_services').hide();
        } else {

            get_rate_data();
        }
    }
});

$(document).on('click', '.shipping_service_sel_btn', function () {
    if (check_weight_entered()) {

        var new_shipping_service_id = $(this).attr('id');
        new_shipping_service_id = new_shipping_service_id.replace('shipping_service_sel_btn_', '');

        $('#order_override_shipping_service_id').val(new_shipping_service_id);
        $('#order_company_packaging_type_id').val(current_packaging_id);
        $('#order_package_height').val($('#ad_hoc_packaging_size_depth').val());
        $('#order_package_width').val($('#ad_hoc_packaging_size_width').val());
        $('#order_package_length').val($('#ad_hoc_packaging_size_length').val());
        save_form();
        return false;
    }
});

function check_weight_entered() {
    if (parseFloat($('#order_shipping_weight').val()) == 0) {

        setTimeout(function () {
            $(".btn-group button").removeClass("active");
        }, 2000);
        $('#order_shipping_weight').focus();
        error_dialog('Weight must be greater than 0');
        return false

    }
    return true
}

function get_rate_data() {
    var url = '/shipping_methods/get_available_shipping_services';

    var weight = $('#order_shipping_weight').val();


    if (weight > 0) {
        $('#available_shipping_services').hide();
        $('#loading_rates').show();
        $('#ad_hoc_packaging_size').hide();
        var order_id = $('#order_info_order_id').text();

        $.ajax({
            url: url,
            data: {
                order_id: order_id,
                weight: weight,
                comp_pack_type_id: current_packaging_id,
                dimensions: get_dimension_data()
            },
            success: function (data) {
                $('#available_shipping_services').html(data).show();
                $('#loading_rates').hide();
            },
            error: function (data) {
                $('#available_shipping_services').hide();
                $('#loading_rates').hide();
                error_dialog('Error Getting Rates: ' + data.responseText);
                console.log('error');
            },
            failure: function (data) {
                $('#available_shipping_services').hide();
                $('#loading_rates').hide();
                error_dialog('Error Getting Rates: ' + data);
                console.log('error');
            }
        })
    }  else {
        alert('no weight');
    }


}

function setWeight(weight) {
    if (weight) {
        $('#curr_weight').html('Scale Weight: ' + weight);
        $('#order_shipping_weight').val(weight);
        console.log('Weight Received: ' + weight);
    }
}

window.addEventListener('message', function (e) {
    console.log('Received command:', e.data.command);
    if (e.data.command == 'serialConnect') {
        console.log('Serial Connect');
        e.source.postMessage({command: 'serialConnect'}, e.origin);
    } else if (e.data.command == 'serialWeight') {
        setWeight(e.data.weight);
    }
});

function setupWeighing() {
    $('#order_complete_text').hide();
    window.setTimeout(function () {
        $('#order_shipping_weight').focus();
    }, 100)
}

$(document).ajaxError(function (event, jqxhr, settings, thrownError) {
    if (settings.url == "order_weighing/update_weight") {
        $("#update-container").html(jqxhr.responseText);
    }
});

$(document).ajaxSuccess(function (event, jqxhr, settings, thrownError) {
    if (settings.url == "order_weighing/update_weight") {
        $("#update-container").html("");
        $('#order_id').val("").focus();
        alertify.success("Shipment Saved");
        $('#curr_weight').html('');
    }
});

$(document).on('click', '#submit-form', function () {
    save_form();
});

function save_form() {
    $('form.order').submit();
    return false;
}


