//$().ready({
//$(').
//});

$(document).on('click', '#postcode_search', function () {
    $('#selAddressList').empty();
    $('#pcaw_results').hide();
    $.ajax({
        url: 'customers/postcode_search',
        data: {
            postcode: $('#txtPostCodeSearch').val(),
            country: $('#customer_address_country').val()
        },
        success: function (response) {
            var data = response.data;
            var count = data.length;
            if (count > 0) {
                $('#pcaw_results').show();

                var i;
                for (i = 0; i < count; i++) {
                    $('#selAddressList').append(new Option(data[i].text, data[i].id));
                }
                selectPCAWAddress(data[0].id);
            }
            else {
                error_dialog('No results found');
            }

        },
        failure: function () {

        },
        complete: function () {

        }
    });
});

$(document).on('change', '#selAddressList', function () {
    selectPCAWAddress($('#selAddressList option:selected').val());
});

function selectPCAWAddress(id) {
    $.ajax({
        url: 'customers/postcode_get_by_id',
        data: {address_id: id},
        success: function (response) {
            var data = response.data;
            if (data) {
                $('#confirm_company').html(data[0].company);
                $('#confirm_address_line_1').html(data[0].line_1);
                $('#confirm_address_line_2').html(data[0].line_2);
                $('#confirm_city').html(data[0].city);
                $('#confirm_county').html(data[0].province);
                $('#confirm_post_code').html(data[0].post_code);
                $('#confirm_country').html(data[0].country_name);
                $('#confirm_country_iso').html(data[0].country_iso2);
            }
        },
        failure: function () {

        },
        complete: function () {

        }
    });
}

$(document).on('click', '#confirm_update_address', function () {
    $('#customer_address_company').val($('#confirm_company').html());
    $('#customer_address_address_1').val($('#confirm_address_line_1').html());
    $('#customer_address_address_2').val($('#confirm_address_line_2').html());
    $('#customer_address_town').val($('#confirm_city').html());
    $('#customer_address_county').val($('#confirm_county').html());
    $('#customer_address_post_code').val($('#confirm_post_code').html());
    $('#customer_address_country').val($('#confirm_country_iso').html());
});


