(function ($) {
    $.fn.extend({

        //pass the options variable to the function
        itemselector: function (options) {


            //Set the default values, use comma to separate the settings, example:
            var defaults = {
                url: "/merchandise_groups/product_js_tree.json",
                item_display: "",
                item_display_default: "",
                icon: "",
                dialog_text: "Please select an item",
                callback: null,
                input_field: ""
            };

            var options = $.extend(defaults, options);

            return this.each(function () {
                var o = options;
                $(this).parent().find('.removable').remove();
                $(this).parent().prepend('<div class="ui-itempicker-dialog" title="' + o.dialog_text + '"><div class="ui-itempicker-tree removable"></div></div>');
                $(this).parent().prepend('<img style="height:18px;" src=" ' + o.icon + ' " class="ui-itempicker-icon removable"/>');
                $(this).parent().prepend('<input class="' + o.item_display.substring(1) + ' removable" type="text" value="' + o.item_display_default + '" readonly=true/>');

                var current_dialog = $(this).parent().find('.ui-itempicker-dialog')[0];
                var current_tree = $(this).parent().find('.ui-itempicker-tree')[0];
                var current_icon = $(this).parent().find('.ui-itempicker-icon')[0];

                var product_tree = $(current_tree).jstree({
                    "json_data": {
                        "ajax": {
                            "url": o.url,
                            "data": function (n) {
                                return {
                                    id: n.attr ? n.attr("id") : 0
                                };
                            }
                        }
                    },
                    "ui": {
                        "select_limit": 1
                    },
                    "themes": {
                        "theme": "default",
                        "dots": false,
                        "icons": true
                    },
                    "plugins": ["themes", "json_data", "ui"]
                });


                product_tree.bind("select_node.jstree", function (event, data) {
                    var current_node = null;
                    var current_node_id = null;
                    var current_node_name = null;

                    try {
                        current_node = data.args[0].id.trim().toLowerCase();
                        current_node_id = current_node.replace('item_', '');
                        current_node_name = $(data.args[0]).text().trim();
                    }
                    catch (e) {
                        current_node = data.args[0][0].id.trim().toLowerCase();
                        current_node_id = current_node.replace('item_', '');
                        current_node_name = $(data.args[0][0]).text().trim();
                    }

                    if (current_node.indexOf('item') != -1) {
                        o.callback(current_node_id, current_node_name, o.input_field);
                        $(current_dialog).dialog("close");
                    }
                });

                $(current_dialog).dialog({
                    autoOpen: false,
                    show: "blind",
                    hide: "fade"
                });

                $(current_icon).click(function () {
                    $(current_dialog).dialog("open");
                });
            });
        }
    });

})(jQuery);

