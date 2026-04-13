function callPageMethod(url, payload, onSuccess) {
    $.ajax({
        url: url,
        type: "POST",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        data: JSON.stringify(payload || {}),
        success: function (response) {
            var result = response.d;

            if (result && result.RedirectUrl && !result.Success) {
                window.location.href = result.RedirectUrl;
                return;
            }

            onSuccess(result);
        },
        error: function () {
            alert("Ocurrió un error al procesar la solicitud.");
        }
    });
}

function initializeTooltips() {
    $(document).tooltip({
        track: false,
        position: {
            my: "left bottom-14",
            at: "left top",
            collision: "none"
        },
        show: false,
        hide: false,
        tooltipClass: "app-tooltip"
    });
}

function initializeDatePicker(selector, options) {
    var defaultOptions = {
        dateFormat: "yy-mm-dd",
        changeMonth: true,
        changeYear: true,
        yearRange: "1950:2050",
        firstDay: 1,
        showOtherMonths: false,
        selectOtherMonths: false
    };

    $(selector).datepicker($.extend({}, defaultOptions, options || {}));
}

function populateSelect(selector, items, includeEmpty, valueField, textField, secondTextField) {
    valueField = valueField || "Id";
    textField = textField || "Name";
    var options = [];

    if (includeEmpty) {
        options.push("<option value=''>Todos</option>");
    }

    $.each(items || [], function (_, item) {
        var text = item[textField] || "";
        if (secondTextField) {
            text = (item[textField] || "") + " " + (item[secondTextField] || "");
        }

        options.push("<option value='" + htmlEncode(item[valueField]) + "'>" + htmlEncode($.trim(text)) + "</option>");
    });

    $(selector).html(options.join(""));
}

function showMessage(selector, message, isError) {
    $(selector).removeClass("error success").addClass(isError ? "error" : "success").text(message || "");
}

function emptyStringToNull(value) {
    return value === "" || value === null || typeof value === "undefined" ? null : value;
}

function emptyToNullableInt(value) {
    return value === "" || value === null || typeof value === "undefined" ? null : parseInt(value, 10);
}

function findById(items, fieldName, id) {
    var targetId = parseInt(id, 10);
    return $.grep(items || [], function (item) {
        return item[fieldName] === targetId;
    })[0];
}

function formatJsonDate(value) {
    if (!value) {
        return "";
    }

    if (typeof value === "string" && value.indexOf("/Date(") === 0) {
        var timestamp = parseInt(value.replace("/Date(", "").replace(")/", ""), 10);
        return formatDateToIso(new Date(timestamp));
    }

    return value.substring ? value.substring(0, 10) : value;
}

function toIsoDate(value) {
    if (!value) {
        return null;
    }

    return value + "T00:00:00";
}

function formatDateToIso(date) {
    var year = date.getFullYear();
    var month = (date.getMonth() + 1).toString();
    var day = date.getDate().toString();

    if (month.length < 2) {
        month = "0" + month;
    }

    if (day.length < 2) {
        day = "0" + day;
    }

    return year + "-" + month + "-" + day;
}

function formatJsonDateTime(value) {
    if (!value) {
        return "";
    }

    if (typeof value === "string" && value.indexOf("/Date(") === 0) {
        var timestamp = parseJsonDateTimestamp(value);
        if (timestamp !== null) {
            return formatDateTimeForLocal(new Date(timestamp));
        }
    }

    var normalizedValue = value;
    if (typeof value === "string" && isIsoDateTimeWithoutTimezone(value)) {
        normalizedValue = value.replace(" ", "T") + "Z";
    }

    var parsedDate = new Date(normalizedValue);
    if (!isNaN(parsedDate.getTime())) {
        return formatDateTimeForLocal(parsedDate);
    }

    return value;
}

function isIsoDateTimeWithoutTimezone(value) {
    return /^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(:\d{2}(\.\d{1,7})?)?$/.test(value || "");
}

function parseJsonDateTimestamp(value) {
    var match = /\/Date\((-?\d+)/.exec(value || "");
    return match ? parseInt(match[1], 10) : null;
}

function formatDateTimeForLocal(date) {
    if (!date || isNaN(date.getTime())) {
        return "";
    }

    if (typeof Intl !== "undefined" && typeof Intl.DateTimeFormat === "function") {
        var locale = (typeof navigator !== "undefined" && navigator.language) ? navigator.language : "es-ES";
        return new Intl.DateTimeFormat(locale, {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
            hour12: true
        }).format(date);
    }

    return date.toLocaleString();
}

function htmlEncode(value) {
    return $("<div />").text(value || "").html();
}
