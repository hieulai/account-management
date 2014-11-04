var Registrations = (function ($) {
    var init = function () {
        $(document).on('click', 'a[data-name="submit"]', function () {
            var $form = $('form');
            if (typeof  $(this).data("target") != "undefined") {
                $form = $('form[data-name="' + $(this).data("target") + '"]');
            }
            $form.submit();
        });

        $(document).on('click', 'input[name="contact_selector"]', function () {
            $('input[data-name="contact-holder"]').val($(this).val());
            $("#user_people_attributes_0_id").val($(this).data("person"));
        });

        $('input[name="contact_selector"]').first().click();
    };

    return {
        init: init
    }
})(jQuery);