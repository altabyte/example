$(function () {
    focus_order_id();

    $("#order_picks_form")
        .bind("ajax:success", function (xhr, data, status) {
            $("#update-container").html(xhr.responseText);
            $('#order_id').val("");
            focus_order_id();
            $('#save_message').html('');
            setupPicking();
        })
        .live("ajax:error", function (evt, xhr, status, error) {
            $('#update-container').html(xhr.responseText);
        });
});


function setupPicking() {
    $("#order_picks")
        .bind("ajax:success", function (xhr, data, status) {

        });

    if (pick_by_scan) {
        window.setTimeout(focus_scan_sku, 100);
    }
}

function focus_scan_sku() {
    $("#scan_sku").select().focus();
}

function focus_order_id() {
    $("#order_id").select().focus();
}

$(document).on('keypress', '#scan_sku', function (e) {
    try_barcode_lookup(e);
});


$(document).on('click', '#submit-form', function (e) {
    e.preventDefault();
    submit_form();
});

function submit_form() {

    if (check_has_qty()) {
        if (valid_for_save()) {
            if (check_complete()) {
                save_form();
            } else {
                var text = 'This order is not complete, do you want to partially fulfil this order?';
                alertify.confirm(text, function (e, str) {
                    save_form();
                }).set({
                    labels: {
                        ok: "YES",
                        cancel: "NO"
                    }
                }).set('closable', false);
            }
        }
    } else {
        var text = 'You have not entered any quantities, are you sure you want to save this order?';
        alertify.confirm(text, function (e, str) {
            save_form();
        }).set({
            labels: {
                ok: "YES",
                cancel: "NO"
            }
        }).set('closable', false);
    }
}

function save_form() {
    showPleaseWait(true);
    var order_id = $('#order_info_order_id').html();

    var pick_items = [];

    picking_rows().each(function () {
        var line_qty = $(this).find('.line_qty');
        if (line_qty.val() > 0) {
            pick_items.push({
                order_detail_id: $(this).data('order_detail_id'),
                qty: line_qty.val(),
                country_code: $(this).find('.country_code select').val(),
                harmonization_code: $(this).find('.har_code').val(),
                item_weight: $(this).find('.item_weight').val()
            })
        }
    });

    $.ajax({
        type: 'POST',
        url: "order_picks/update_multiple_picks",
        data: {
            order_id: order_id,
            pick_items: pick_items
        },
        success: function (result) {
            showPleaseWait(false);
            if (result.success) {
                $("#update-container").html("");
                $('#order_id').html('');
                focus_order_id();
                alertify.success("Shipment Saved");
            } else {
                error_dialog(result.message);
            }
        },
        failure: function (result) {
            $('#pnl_results').html('<p>Error getting order details</p>');
            error_dialog("Error saving fulfilment, please refresh the page and try again");
            showPleaseWait(false);
        },
        dataType: "json",
        async: false
    });
}

function valid_for_save() {
    if (check_weights() && !requires_information()) {
        return true;
    } else {
        return false;
    }
}

$(document).on('click', '#pick-all', function () {
    picking_rows().each(function (index) {
        if ($(".line_ordered_qty", this).text() > 0) {
            $(".line_qty", this).val($(".line_ordered_qty", this).text());
        }
    });
});

$(document).on("keydown", "#tbl_picks .line_qty", function (e) {
    table_key_press(e, this);
});

$(document).on('change', '.number_only, input[type=number]', function (e) {
    var target = e.currentTarget;
    try {
        var max = parseFloat($(target).parent().prev('td').text());
        var val = parseFloat(target.value);

        if (val > max) {
            var set_focus = function () {
                $(target).val('').focus().select();
            };
            error_dialog("You picked a quantity greater than the quantity ordered.  I'll now reset the value, please re-enter.", function () {
                window.setTimeout(set_focus, 300)
            });

        }
    }
    catch (err) {
    }
});

function try_barcode_lookup(e) {

    var scan_sku = $('#scan_sku');
    var scan_error = $('#scan_error');

    scan_error.hide();
    if (e.which == 13) {
        var barcode = scan_sku.val();
        var new_barcode;
        var found = false;

        scan_sku.val("");
        // try as entered
        console.log("Trying " + barcode);
        found = check_for_sku(barcode);

        //not found try with checkdigit
        if (!found) {
            new_barcode = barcode.substring(0, barcode.length - 1);
            console.log("Trying " + new_barcode);
            found = check_for_sku(new_barcode);
        }

        // try float then string (removes leading 0s)
        if (!found) {
            new_barcode = parseFloat(barcode);
            new_barcode = new_barcode.toString();
            console.log("Trying " + new_barcode);
            found = check_for_sku(new_barcode);
        }

        //not found try with checkdigit
        if (!found) {
            new_barcode = new_barcode.substring(0, new_barcode.length - 1);
            console.log("Trying " + new_barcode);
            found = check_for_sku(new_barcode);
        }

        if (!found) {
            scan_error.show();
        } else {
            check_auto_complete();
        }
        focus_scan_sku();

        e.preventDefault();
    }
}

function check_for_sku(barcode) {
    var found = false;
    picking_rows().each(function () {
        if ($(this).find('[id^=pick_sku_]').html() == barcode) {
            found = true;
            if ($(this).find('.line_qty').val() == "") {
                $(this).find('.line_qty').val(1)
            } else {
                var max = parseFloat($(this).find('.line_ordered_qty').text());
                var qty = ($(this).find('.line_qty').val());

                if (qty >= max) {
                    error_dialog("You picked a quantity greater than the quantity ordered.  I'll now reset the value, please re-enter.");
                } else {

                    qty = parseInt(qty) + 1;
                    $(this).find('.line_qty').val(qty)
                }
            }
            $(this).find('[id^=pick_sku_]').removeAttr('style');
        }
    });
    return found
}

function check_complete() {
    var complete = true;
    var qty_picked = 0;
    picking_rows().each(function () {
        var max = parseFloat($(this).find('.line_ordered_qty').text());
        var qty = parseFloat(($(this).find('.line_qty').val()));
        qty_picked += qty;
        if (qty != max) {
            complete = false;
        }
    });
    return complete;
}

function check_has_qty() {
    var result = false;
    picking_rows().each(function () {
        var qty = parseFloat(($(this).find('.line_qty').val()));
        if (qty > 0) {
            result = true;
        }
    });
    return result;
}

function check_auto_complete() {
    var complete = check_complete();
    if (complete && !requires_information()) {
        submit_form();
    }
}

function check_weights() {
    var ok = true;
    $('.item_weight').each(function () {
        var weight = parseFloat($(this).val());
        if (weight && weight > max_item_weight) {
            $('#save_message').html('Please check item weights (cannot be more than ' + max_item_weight + 'kg)');
            ok = false;
        }
    });
    return ok;
}

function requires_information() {
    if (country_requires_info) {
        return check_required_info(country_requires_info.item_county_of_origin_required, country_requires_info.item_weight_required, country_requires_info.harmonization_code_required);
    } else {
        return false;
    }
}

function check_required_info(country, weight, h_code) {

    var required = false;
    picking_rows().each(function () {

        var country_code = $(this).find('.country_code select').val();
        var item_weight = $(this).find('.item_weight').val();
        var har_code = $(this).find('.har_code').val();

        if (country && !country_code) {
            required = true;
        }
        if (weight && !item_weight) {
            required = true;
        }
        if (h_code && !har_code) {
            required = true;
        }

        if (required) {
            $('#save_message').html('Please Check Missing Information');
        }
    });
    return required;
}

function picking_rows() {
    return $('#tbl_picks tr:gt(0)');
}