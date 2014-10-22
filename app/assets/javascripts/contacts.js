var Contact = (function ($) {
    var init = function () {
        $(document).on('click', 'input[data-class="association_type"]', function () {
            var $container = $(this).closest("div");
            var $destroy = $container.find('input[name$="[_destroy]"]');
            $destroy.val($(this).is(":checked") ? "false" : "true");
        })
    };

    return {
        init: init
    }
})(jQuery);