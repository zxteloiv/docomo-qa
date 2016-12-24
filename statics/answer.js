
if (typeof jQuery === "undefined") {
    throw new Error("jQuery lib is missing.");
}

var handle_submit = function() {
    var query = $("#query").val();
    $.ajax('/answer', {
        method: "POST",
        dataType: "json",
        data: {
            q: query,
            lat: 39.983424,
            lng: 116.322987,
        },
        success: function(data, state, jqXHR) {
            if (!data || !('errno' in data) || !('errmsg' in data) ||
                    !('data' in data)) {
                console.log("returned data is not valid.");
                return;
            }

            if (data.errno > 0) {
                console.log("server error: " + data.errno + "\n" + data.errmsg);
                return;
            }

            render_data(data.data, data.reprtype);
        },
        error: function(jqXHR, state, err) {
            console.log(state + ": answer server api error\n" + err)
        }
    });

    return false;
};

var render_data = function(pois, reprtype) {
    $("#searchresult").html("")
    for (var idx in pois) {
        var poi = pois[idx];

        var row = $("<div>").addClass("row");

        var name = $("<div>").addClass("col-md-2");
        var zh_name = $("<span>");
        if (poi.name) { zh_name.text(poi.name); }
        else if (poi.zh) { zh_name.text(poi.zh); }
        var en_name = $("<span>");
        if (poi.en) { en_name.text(poi.en); }
        var ja_name = $("<span>");
        if (poi.ja) { ja_name.text(poi.ja); }
        name.append(zh_name);
        name.append('<br>').append(en_name);
        name.append('<br>').append(ja_name);

        var addr = $("<span>").addClass("col-md-3");
        if (poi.addr) {
            addr.text(poi.addr);
        }

        var rating = $("<span>").addClass("col-md-1");
        if (poi.rating) {
            rating.text(poi.rating);
        }

        var phone = $("<span>").addClass("col-md-1");
        if (poi.phone) {
            phone_str = poi.phone.replace(/[, \|]/g, '$& ');
            phone.text(phone_str)
        }

        var tag = $("<span>").addClass("col-md-1");
        if (poi.class) {
            tag.text(poi.class)
        }

        var loc = $("<span>").addClass("col-md-2");
        if (poi.lng && poi.lat) {
            loc.text(poi.lng + "," + pois[idx].lat)
        }

        var more = $("<span>").addClass("col-md-1");
        if (poi.url) {
            more.append($("<a>").attr("href", poi.url)
                .attr("target", "_blank").text("more"));
        }

        row.append(name);
        row.append(addr);
        row.append(rating);
        row.append(phone);
        row.append(tag);
        row.append(loc);
        row.append(more);

        $("#searchresult").append(row);

        if (poi.general_val && poi.general_func) {
            $("#searchresult").append(
                $("<div>").addClass("row").append(
                    $("<span>").addClass("col-md-12")
                    .text(poi.general_func + ": " + poi.general_val)
                    )
                )
        }

        $("#searchresult").append("<hr>");
    }
};

+function($){
    $("#searchform").submit(handle_submit);
}(jQuery);
