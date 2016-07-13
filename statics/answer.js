
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
                    !('data' in data) || !('reprtype' in data)) {
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
        var row = $("<div>").addClass("row");
        var name = $("<span>").text(pois[idx].name).addClass("col-md-2");
        var addr = $("<span>").text(pois[idx].addr).addClass("col-md-3");
        var rating = $("<span>").text(pois[idx].rating).addClass("col-md-1");
        var phone = $("<span>").text(pois[idx].phone).addClass("col-md-1");
        var tag = $("<span>").text(pois[idx].class).addClass("col-md-1");
        var loc = $("<span>")
            .text(pois[idx].lng + "," + pois[idx].lat)
            .addClass("col-md-2");
        var more = $("<span>").addClass("col-md-1")
            .append($("<a>").attr("href", pois[idx].url)
                    .attr("target", "_blank").text("more"));

        row.append(name);
        row.append(addr);
        row.append(rating);
        row.append(phone);
        row.append(tag);
        row.append(loc);
        row.append(more);

        $("#searchresult").append(row);
    }
};

+function($){
    $("#searchform").submit(handle_submit);
}(jQuery);
