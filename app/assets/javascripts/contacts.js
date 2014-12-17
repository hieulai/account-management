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

        $(document).on('click', 'input[name="contact_selector"]', function () {
            $('input[data-name="relationship_contact"]').val($(this).val());
        });

        $(document).on('click', 'input[name="user[job_type]"]', function () {
            var $containers = $('div[data-class="job_type"]');
            $containers.each(function (index) {
                $(this).find('input[data-name="association_type"]').attr("checked", false);
                $(this).find('input[name$="[_destroy]"]').val("true");
            });
            $containers.hide();

            var $selector = $('div[data-name="' + $(this).val() + '"]');
            if ($selector.data("name") != "self_employed"){
                $selector.each(function (index) {
                    $(this).find('input[name$="[_destroy]"]').val("false");
                });
            }
            $selector.show();
        });

        $(document).on('click', 'input[name="association_type_Employee"]', function () {
            $('div[data-name="role"]').toggle();
            $('select[name="role"]').change();
        });
    };

    return {
        init: init
    }
})(jQuery);