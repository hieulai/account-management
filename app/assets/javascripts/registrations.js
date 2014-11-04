var Registrations = (function ($) {
    var init = function () {
        $(document).on('click', 'a[data-name="submit"]', function () {
            var $form = $('form');
            if (typeof  $(this).data("target") != "undefined") {
                $form = $('form[data-name="' + $(this).data("target") + '"]');
            }
            $form.submit();
        });

        $(document).on('click', 'a[data-name="override_submit"]', function () {
            var $form = $('form');
            var $selectedUser = $('input[name="contact_selector"]:checked');
            $('input[data-name="contact-holder"]').val($selectedUser.val());
            $("#user_people_attributes_0_id").val($selectedUser.data("person"));
            $form.submit();
        });
    };

    return {
        init: init
    }
})(jQuery);