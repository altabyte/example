// ###This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery/jquery.js
//= require jquery/jquery_ujs.js
//= require jquery.remotipart
//= require jquery/jquery-ui.js
//= require i18n
//= require pdfobject
//= require jquery.datetimepicker
//= require autocomplete-rails
//= require jquery.marquee
//= require jquery.cookie
//= require jquery/jquery.blockUI.js
//= require i18n/translations
//= require dataTables/jquery.dataTables
//= require jquery/jquery.dataTables.columnFilter.js
//= require jquery/fnSetFilteringDelay.js
//= require bootstrap
//= require notifications
//= require alertify.min
//= require zozo.tabs.min
//= require_self

var isChromeApp = false;
var blockTable = true;

window.addEventListener('message', function (e) {
    console.log('Received command:', e.data.command);
    if (e.data.command == 'isChromeApp') {
        isChromeApp = e;
    }
});

var datatable = false;
$(document).ready(function () {

    $('input.ui-datepicker').datepicker({
        showOn: "focus",
        buttonImage: "/assets/calendar.gif",
        buttonImageOnly: true,
        dateFormat: 'dd-mm-yy',
        changeMonth: true,
        changeYear: true,
        yearRange: 'c-100:c+10'
    });

    $('input.ui-datetimepicker').datetimepicker({
        showOn: "focus",
        buttonImage: "/assets/calendar.gif",
        buttonImageOnly: true,
        dateFormat: 'dd-mm-yy',
        changeMonth: true,
        changeYear: true,
        yearRange: 'c-100:c+10'
    });

    $("#" + $.cookie("current_menu")).toggleClass("collapsed");
    $("#" + $.cookie("current_menu")).toggleClass("current");

    $("div[class~='alert-success']").fadeOut(20000);

    alertify.defaults.transition = "slide";
    alertify.defaults.theme.ok = "btn btn-primary alertify-ok";
    alertify.defaults.theme.cancel = "btn btn-danger alertify-cancel";
    alertify.defaults.theme.input = "form-control";
    alertify.defaults.glossary.title = "Order Manager";

});


$(document).bind("ajaxStart.dataTable", function () {
    if (blockTable) {
        $('.dataTable').block({message: '', overlayCSS: {opacity: '0.3'}});
    }
});

$(document).bind("ajaxStop.dataTable", function () {
    if (blockTable) {
        $('.dataTable').unblock();
    }
});


function update_information_panel() {
    blockTable = false;
    $.ajax({
        type: 'GET',
        url: '/home/information_panel',
        success: function (result) {
            $('#information_panel').html(result);
        },
        complete: function () {
            blockTable = true;
        }
    });
}

function getURLParameter(name) {
    return decodeURI(
        (RegExp(name + '=' + '(.+?)(&|$)').exec(location.search) || [, null])[1]
    );
}

function click_event() {
    var mobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent);
    return mobile ? "touchstart" : "mousedown";
}

$(function () {
    $("#nav .header").click(function () {
        if ($(this).parent().hasClass('collapsed')) {
            $.cookie("current_menu", $(this).attr('id'));
        } else {
            $.cookie("current_menu", "");
        }
        $(this).parent().toggleClass("collapsed");
    });

    $("#nav .single_nav_item").click(function () {
        $.cookie("current_menu", "");
    });
});

$(function () {
    $('form[data-update-target]').live('ajax:success', function (evt, data) {
        var target = $(this).data('update-target');
        $('#' + target).html(data);
    });
});

function table_key_press(e, field) {
    if (e.which == 39) {
        e.preventDefault();
        new_field = $(field).closest('td').nextAll('td').find(':input:visible:not([readonly])').first();
        if (new_field.length == 0) {
            new_field = $(field).parents('tr').nextAll('tr').first().find(':input:visible:not([readonly])').first();
        }
        $(new_field).focus();
        setTimeout("$(new_field).select()", 1);
    } else if (e.which == 37) {
        e.preventDefault();
        new_field = $(field).closest('td').prevAll('td').find(':input:visible:not([readonly])').first();
        if (new_field.length == 0) {
            new_field = $(field).parents('tr').prevAll('tr').first().find(':input:visible:not([readonly])').last();
        }
        $(new_field).focus();
        setTimeout("$(new_field).select()", 1);
    } else if (e.which == 40) {
        e.preventDefault();
        if ($(field).parents('tr').nextAll('tr').first().find('td:eq(' + $(field).closest('td').index() + ')').find('input').css('display') == 'none') {
            new_field = $(field).parents('tr').nextAll('tr').first().find('td:eq(' + ($(field).closest('td').index() - 1) + ')').find(':input:visible:not([readonly])').first();
        } else {
            new_field = $(field).parents('tr').nextAll('tr').first().find('td:eq(' + $(field).closest('td').index() + ')').find(':input:visible:not([readonly])').first();
        }
        if (!($(new_field).hasClass('ui-autocomplete-input')) && !($(new_field).attr('autocomplete') == 'on')) {
            $(new_field).focus();
            setTimeout("$(new_field).select()", 1);
        }
    } else if (e.which == 38) {
        e.preventDefault();
        if ($(field).parents('tr').prevAll('tr').first().find('td:eq(' + $(field).closest('td').index() + ')').find('input').css('display') == 'none') {
            new_field = $(field).parents('tr').prevAll('tr').first().find('td:eq(' + ($(field).closest('td').index() - 1) + ')').find(':input:visible:not([readonly])').first();
        } else {
            new_field = $(field).parents('tr').prevAll('tr').first().find('td:eq(' + $(field).closest('td').index() + ')').find(':input:visible:not([readonly])').first();
        }
        if (!($(new_field).hasClass('ui-autocomplete-input')) && !($(new_field).attr('autocomplete') == 'on')) {
            $(new_field).focus();
            setTimeout("$(new_field).select()", 1);
        }
    }
}

function yn_dialog(selector, text, yes_callback, no_callback) {
    alertify.confirm(text, function (e, str) {
        // str is the input text
        if (e) {
            if (yes_callback) {
                yes_callback();
            }
        } else {
            if (no_callback) {
                no_callback();
            }
        }
    }).set('labels', {ok: 'Yes', cancel: 'No'})
        .set('closable', false);
}

function error_dialog(text, ok_callback) {
    alertify.alert(text, function () {
        $(this).dialog("close");
        if (ok_callback) {
            ok_callback();
        }
    }).set('labels', {ok: alertify.defaults.glossary.ok, cancel: alertify.defaults.glossary.cancel})
}

function showPleaseWait(show) {
    if (show) {
        $.blockUI({
            baseZ: 2000
        });
    } else {
        $.unblockUI();
    }

}

function save_successful() {
    alertify.success("Save Successful");
}


$(document).on('keydown', '.number_only', function (event) {
    if ((!event.shiftKey && !event.ctrlKey && !event.altKey) && ((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105) || event.keyCode == 110 || event.keyCode == 190)) {
    }
    else if (event.keyCode != 8 && event.keyCode != 46 && event.keyCode != 37 && event.keyCode != 39 && event.keyCode != 9 && event.keyCode != 189) // not esc, del, left or right
    {
        event.preventDefault();
    }
});