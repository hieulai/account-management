var Map = (function ($) {

    var countryRestrict = { 'country': 'us' };
    var componentForm = {
        locality: 'long_name',
        administrative_area_level_1: 'short_name',
        postal_code: 'short_name'
    };

    var init = function () {
        initAutoComplete('[data-name="address"]');
    };

    var initAutoComplete = function (selector) {
        var $addressInputs = $(selector);

        if ($addressInputs.length == 0) {
            return;
        }

        for (var i = 0; i < $addressInputs.length; i++) {
            var autocomplete = new google.maps.places.Autocomplete($addressInputs[i], { types: ['geocode'], componentRestrictions: countryRestrict });
            if ( $($addressInputs[i]).data("id") == "main") {
                google.maps.event.addListener(autocomplete, 'place_changed', function () {
                    fillInAddress(this);
                });
            }

            google.maps.event.addDomListener($addressInputs[i], 'keydown', function (e) {
                if (e.keyCode == 13) {
                    e.preventDefault();
                }
            });
        }
    };

    var fillInAddress = function (autocomplete) {
        var place = autocomplete.getPlace();
        for (var key in componentForm) {
            $('[data-name="' + key + '"]').val("");
        }
        for (var i = 0; i < place.address_components.length; i++) {
            var addressType = place.address_components[i].types[0];
            if (componentForm[addressType]) {
                var val = place.address_components[i][componentForm[addressType]];
                $('[data-name="' + addressType + '"]').val(val);
            }
        }
    };

    return {
        init: init
    }
})(jQuery);