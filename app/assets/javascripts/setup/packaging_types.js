function setupPackagingTypes() {

    $('#packaging_types').dataTable({
        "sPaginationType": "full_numbers",
        bJQueryUI: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#packaging_types').data('source'),
        bFilter: true,
        "aoColumnDefs": [
            {"bSortable": false, "aTargets": [2, 1]},
            {"sWidth": "15%", "aTargets": [2]},
            {"sWidth": "30%", "aTargets": [1]}
        ]
    }).fnSetFilteringDelay();

    $("#packaging_types_filter").append("<img id='new_company_packing_type' src='" + new_button_src + "' class='new-button'/>");

    $('#packaging_types .delete-button').live('click', function (event) {
        delete_packaging_type(this.id);
    });


    $('#company_packaging_type_form').live("ajax:success", function (evt, data, status, xhr) {
        $('#company_packaging_type_form').html(xhr.responseText);
        $('#new_packaging_type_dialog').dialog('close');
    }).live("ajax:error", function (evt, xhr, status, error) {
        $('#company_packaging_type_form').html(xhr.responseText);
        var text = $('#company_packaging_type_packaging_type_id option:selected').text();

        if (text == 'Custom') {
            $('#custom_size_params').show();

        } else {
            $('#custom_size_params').hide();
        }
    });

    $('#new_packaging_type_dialog').live("dialogclose", function () {
        $('#packaging_types').dataTable().fnDraw();
    });

    $('#new_company_packing_type').live('click', function (event) {
        var url = '/company_packaging_types/new'
        $.ajax({
            url: url,
            success: function (data) {
                $('#new_packaging_type_dialog').html(data);
                $('#new_packaging_type_dialog').dialog('open');
                update_packing_type_name();
            },
            failure: function () {
                console.log('error');
            }
        });
    });

    $('#new_packaging_type_dialog').dialog({
        height: 'auto',
        width: '600px',
        modal: true,
        autoOpen: false
    });

    $(document).on('change', '#company_packaging_type_packaging_type_id', function () {
        update_packing_type_name();
    })


}


function update_packing_type_name() {
    var text = $('#company_packaging_type_packaging_type_id option:selected').text();
    $('#company_packaging_type_name').val(text);

    if (text == 'Custom') {
        $('#custom_size_params').show();

    } else {
        $('#custom_size_params').hide();
    }
}

function delete_packaging_type(id) {
    var url = '/company_packaging_types/destroy/' + id;
    url = url.replace('delete_packaging_type_', '');

    var options = {
        url: url,
        text: "Are you sure you want to delete this packaging type?",
        on_completed: function () {
            $('#packaging_types').dataTable().fnDraw();
        }
    };
    delete_dialog(options);
}

