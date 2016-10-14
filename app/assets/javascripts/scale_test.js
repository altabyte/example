var buffer = 0;
var x_walker = 0, last_x = 0, last_y = 0;
var socket;
var host = "ws://" + scale_ip_address + ":5331/write_anything_here.php";

$(document).ready(function () {


    function connect() {

        try {

            socket = new WebSocket(host);
            message('<p class="event">Socket Status: ' + socket.readyState);

            socket.onopen = function () {
                message('<p class="event">Socket Status: ' + socket.readyState + ' (open)');
            };

            socket.onmessage = function (msg) {

                if (msg.data.toString().trim()) {
                    var weight = msg.data.toString().trim().match(/\d+/g).join('.');
                    if (!isNaN(weight)) {
                        message('<p class="message">Response from serial : ' + parseFloat(weight));
                        $('#curr_weight').html(weight);
                    }
                }
            };

            socket.onclose = function () {
                message('<p class="event">Socket Status: ' + socket.readyState + ' (Closed)');
                socket.close();
            }

            socket.onerror = function (error) {
                message('<p class="event">Socket Status: ' + error + ' (Closed)');
            }

        } catch (exception) {

            message('<p>Error' + exception);
        }

    }

    function send() {

        var text = $('#text').val();

        if (text == "") return;

        try {
            socket.send(text);
            message('<p class="event">Sent: ' + text);
            $('#text').val("");
        } catch (exception) {
            message('<p class="warning">Connection problem.</p>');
        }

    }

    function plotCanvas(x, y) {
        var context = $('#dataCanvas')[0].getContext("2d");
        if (y > last_y) context.strokeStyle = "red";
        else context.strokeStyle = "green";
        context.lineJoin = "round";
        context.lineWidth = 2;
        context.beginPath();
        context.moveTo(last_x, last_y);
        context.lineTo(x, y);
        context.closePath();
        context.stroke();
        last_x = x;
        last_y = y;
    }

    function message(msg) {
        $('#dataLog').append(msg + "<br />");
        $('#dataLog').scrollTop($('#dataLog').height());
        $("#dataLog").animate({scrollTop: $("#dataLog").attr("scrollHeight")}, 250);
    }

    $('#text').keypress(function (event) {
        if (event.keyCode == '13') {
            send();
        }
    });

    $('#send').click(function () {
        send();
    });

    $('#disconnect').click(function () {
        message("Disconnecting " + "<br />");
        socket.close();

    });

    $('#connect').click(function () {
        message("Connecting " + "<br />");
        connect();
    });


});