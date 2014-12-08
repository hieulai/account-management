var Map = (function ($) {

    var countryRestrict = { 'country': 'us' };
    var init = function () {
        initAutoComplete('[data-name="address"]');
    };

    var initAutoComplete = function (selector) {
        var $addressInputs = $(selector);

        if ($addressInputs.length == 0) {
            return;
        }

        for (var i = 0; i < $addressInputs.length; i++) {
            new google.maps.places.Autocomplete($addressInputs[i], { types: ['geocode'], componentRestrictions: countryRestrict });
            google.maps.event.addDomListener($addressInputs[i], 'keydown', function (e) {
                if (e.keyCode == 13) {
                    e.preventDefault();
                }
            });
        }
    };

    return {
        init: init
    }
})(jQuery);