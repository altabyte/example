(function () {

    // Object that holds all data on the plugin
    var P = {name: "AdobeReader", status: -1, version: null, minVersion: "11,0,0,0"},
        $ = PluginDetect;

    // $.onBeforeInstantiate(P.name, function($){$.message.write("[ $.onBeforeInstantiate(...) ]");})


    // Return text message based on plugin detection result
    var getStatusMsg = function (obj) {
        var Msg1 = " [PDF documents may be displayed using your browser with the Adobe plugin ";
        var Msg2 = "(but <object>/<embed> tags cannot be used) ";
        var Msg3 = "and/or using the Adobe Reader standalone application.]";

        if (obj.status == 1) return "installed & enabled, version is >= " +
            obj.minVersion + Msg1 + Msg3;
        if (obj.status == 0) return "installed & enabled, version is unknown" + Msg1 + Msg3;
        if (obj.status == -0.1) return "installed & enabled, version is < " +
            obj.minVersion + Msg1 + Msg3;
        if (obj.status == -0.15) return "installed but not enabled for <object>/<embed> tags. " +
            "This result occurs for Internet Explorer when the Adobe Reader ActiveX " +
            "control is disabled in the add-ons menu." + Msg1 + Msg2 + Msg3;
        if (obj.status == -1) return "not installed or not enabled " +
            "[The browser plugin is not installed/not enabled. However, it is still possible " +
            "that the Adobe Reader standalone application may be on your computer and can " +
            "display PDF documents. Note: PluginDetect can only detect browser plugins, " +
            "not standalone applications.]";
        if (obj.status == -1.5) return "unknown " +
            "[Unable to determine if the Adobe Reader plugin is installed and able " +
            "to display PDF documents in your browser. " +
            "This result occurs for Internet Explorer when ActiveX is disabled and/or " +
            "ActiveX Filtering is enabled. " +
            "Note: the Adobe Reader plugin can display a PDF document with or without " +
            "ActiveX in Internet Explorer. Without ActiveX, however, we cannot detect " +
            "the presence of the plugin and we cannot use <object>/<embed> tags to display a PDF.]";

        if (obj.status == -3) return "error...bad input argument to PluginDetect method";
        return "unknown";

    };   // end of getStatusMsg()


    // Add text to output node
    var docWrite = function (text) {

        var out = document.getElementById("adobeReaderCheck");  // node for output text
        if (text) {
            text = text.replace(/&nbsp;/g, "\u00a0");
            out.appendChild(document.createTextNode(text));
        }
        out.appendChild(document.createElement("br"));
        //out.appendChild(document.createTextNode($.browser.isIE));
    };

    var writeAcrobatInfo = function (version, error) {
        document.getElementById('adobeVersion').appendChild(document.createTextNode(version));
        document.getElementById('adobeError').appendChild(document.createTextNode(error));
    };


    if ($.isMinVersion) {
        // Detect Plugin Status
        P.status = $.isMinVersion(P.name, P.minVersion);
        if ($.OS == 2 && $.browser.isChrome) {
            writeAcrobatInfo('Adobe Reader', "Please use Apple Safari on Apple devices, Chrome has issues with the Acrobat plugin");
        } else {
            if (P.status == 1) {
                writeAcrobatInfo('Adobe Reader', 'Good to go');
            } else if (P.status == 0) {
                writeAcrobatInfo('Adobe Reader', 'Good to go, but version is unknown.');
            } else if (P.status == -0.1) {
                writeAcrobatInfo('Adobe Reader', 'Version is less than the required version, please upgrade.');
            } else {
                writeAcrobatInfo('Adobe Reader Not Installed', "Please download Adobe Reader if it's not installed or enable the plugin");
            }
        }

    }


    if ($.browser.isIE) {
        docWrite("ActiveX enabled / ActiveX scripting enabled: " +
            ($.browser.ActiveXEnabled ? "true" : "false [this prevents detection of the plugin in Internet Explorer]")
        );
        docWrite("ActiveX Filtering enabled: " +
            ($.browser.ActiveXFilteringEnabled ? "true [this prevents detection of the plugin in Internet Explorer]" : "false")
        );
    }

    var writeBrowserInfo = function (version, error) {
        document.getElementById('browserVersion').appendChild(document.createTextNode(version));
        document.getElementById('browserError').appendChild(document.createTextNode(error));
    };

    if ($.browser.isChrome) {
        writeBrowserInfo('Google Chrome', 'Correct');
    } else if ($.browser.isSafari) {
        writeBrowserInfo('Apple Safari', 'Correct');
    } else {
        writeBrowserInfo('Not Supported', 'OrderManager is not supported on you browser.  Please use Google Chrome or Apple Safari.');
    }


})();    // end of function


