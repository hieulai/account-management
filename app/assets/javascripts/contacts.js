var Contact = (function ($) {
    var init = function () {
        $(document).on('click', 'input[data-name="association_type"]', function () {
            var $container = $(this).closest("div");
            var $destroy = $container.find('input[name$="[_destroy]"]');
            $destroy.val($(this).is(":checked") ? "false" : "true");
        });

        $(document).on('click', 'a[data-name="submit"]', function () {
            var $form = $('form[data-name="' + $(this).data("target") + '"]');
            $form.submit();
        });
    };

    return {
        init: init
    }
})(jQuery);