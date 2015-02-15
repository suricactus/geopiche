(function() {
    var AJAX_URL = './data/result.json';
    var AJAX_URL = './data/test1.json';
    var HIDE_POPUP_TIMEOUT = 200;
    var ZOOM_DBLCLICK_MARKER = 13;
    var map = L.map('map').setView([43, 26], 7);
    var markerTimeouts = {};

L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
}).addTo(map);

    jQuery.get(AJAX_URL)
        .then(function(result) {
            for (var i = 0, l = result.length; i < l; i+=10) {
                var item = result[i];
                var marker = L.marker(item.latLng);
                
                marker.bindPopup(buildPopup(item));
                marker.on('click', function (e) {
                });
                marker.on('dblclick', function (e) {
                    map.setView(e.latlng);
                    map.setZoom(ZOOM_DBLCLICK_MARKER);
                });
                marker.on('mouseover', function (e) {
                    clearTimeout(markerTimeouts[marker.leaflet_id]);
                    this.openPopup();
                });
                marker.on('mouseout', function (e) {
                    clearTimeout(markerTimeouts[marker.leaflet_id]);

                    markerTimeouts[marker.leaflet_id] = setTimeout(function() {
                        //this.closePopup();
                    }.bind(this), HIDE_POPUP_TIMEOUT);
                });
                marker.addTo(map)
            }
        });

    var buildPopup = function(item) {
        var html = '';

        html += '<span style="text-transform:capitalize;">';
        html += item.name;
        html += '</span>';
        //html += '<div>';
        //html += '<button>Up</button>'
        //html += '</div>';

        return html;
    };
})();
