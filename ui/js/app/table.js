(function() {
    var AJAX_URL = '../data/result.json';
    var $table = $('#table');

    jQuery.get(AJAX_URL)
        .then(function(result) {
            for (var i = 0, l = result.length; i < l; i+=10) {
                var item = result[i];
                var row = buildRow(result[i]);               
 
                $table.append(row);
            }
        });

    var buildRow = function(item) {
        var html = '';

        html += '<tr>';
        html += '<td>'
        html += item.city;
        html += '</td>';
        html += '</tr>';

        return html;
    };
})();
