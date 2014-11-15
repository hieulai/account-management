// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
var Application = (function ($) {
    var init = function(){
        setupTrClickable();
    };

    var setupTrClickable = function () {
        $(document).on('click', 'tr[data-name="clickable"]', function (e) {
            var $link = $(this).find('a[data-name="clickable-link"]');
            if (typeof $link.attr("target") != "undefined")
                window.open($link.attr("href"), $link.attr("target"));
            else
                window.location = $link.attr("href");
        })

        $(document).on('click', 'tr.clickable input', function (e) {
            e.preventDefault();
            e.cancelBubble = true;
            return false;
        });
    };

    return {
        init: init
    }

})(jQuery);

$(document).ready(function () {
    Application.init();
});