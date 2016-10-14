//=require_self

function setupShippingMatrices() {
    root = this;
    root.oTable = $('#shipping_matrices_table').dataTable({
        sPaginationType: "full_numbers",
        bJQueryUI: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#shipping_matrices_table').data('source'),
        "bFilter": false,
        "aoColumnDefs": [
            {"bSortable": false, "aTargets": [7]}
        ]
    }).fnSetFilteringDelay();

    $('#import_dialog').dialog({
        autoOpen: false,
        modal: true,
        width: 500
    });

    $('#import_matrix_form')
        .live("ajax:success", function (evt, data, status, xhr) {
            $('#shipping_matrices_table').dataTable().fnDraw();
            $("#import_dialog").dialog('close');
        })
        .live("ajax:error", function (evt, xhr, status, error) {
            $('#import_error').html(xhr.responseText);

            setupFileSelect();

        });

    setupFileSelect();


};

$(document).on('click', '#download_file', function () {
    window.location.href = "/shipping_matrices/download_file.csv";
});

$(document).on('click', '#upload_file', function () {
    $('#import_error').html('');
    $('#import_dialog').dialog('open');
});
