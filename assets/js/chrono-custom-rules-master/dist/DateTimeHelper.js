"use strict";
exports.__esModule = true;
exports.DateTimeHelper = void 0;
var DateTimeHelper = /** @class */ (function () {
    function DateTimeHelper() {
    }
    DateTimeHelper.isSameDay = function (dateA, dateB) {
        if (!DateTimeHelper.isDateObject(dateA)) {
            dateA = new Date(dateA);
        }
        if (!DateTimeHelper.isDateObject(dateB)) {
            dateB = new Date(dateB);
        }
        return DateTimeHelper.toStandardDateString(dateA) === DateTimeHelper.toStandardDateString(dateB);
    };
    DateTimeHelper.today = function () {
        var dateObj = new Date();
        dateObj.setHours(0, 0, 0, 0);
        return dateObj;
    };
    DateTimeHelper.tomorrow = function () { return (DateTimeHelper.addDays(DateTimeHelper.today(), 1)); };
    DateTimeHelper.addDays = function (date, days) {
        if (days === void 0) { days = 0; }
        var clonedDate = new Date(date);
        return new Date(clonedDate.setDate(clonedDate.getDate() + days));
    };
    DateTimeHelper.addTime = function (date, time) {
        if (time === void 0) { time = 0; }
        var clonedDate = new Date(date);
        return new Date(clonedDate.getTime() + time);
    };
    DateTimeHelper.addSeconds = function (date, seconds) {
        if (seconds === void 0) { seconds = 0; }
        return (DateTimeHelper.addTime(date, seconds * 1000));
    };
    DateTimeHelper.addMinutes = function (date, minutes) {
        if (minutes === void 0) { minutes = 0; }
        return (DateTimeHelper.addSeconds(date, minutes * 60));
    };
    DateTimeHelper.resetTime = function (date) {
        if (typeof date === 'string' && date.length === 10) {
            // if the date is a string with only the date, add the time, otherwise the date will be set to the current time in GMT
            date += ' 00:00:00';
        }
        var clonedDate = new Date(date);
        clonedDate.setHours(0, 0, 0, 0);
        return clonedDate;
    };
    DateTimeHelper.toStandardDateString = function (genericDate, separator) {
        if (separator === void 0) { separator = '-'; }
        var date = !DateTimeHelper.isDateObject(genericDate) ? DateTimeHelper.resetTime(genericDate) : genericDate;
        return [
            date.getFullYear(),
            ('0' + (date.getMonth() + 1)).slice(-2),
            ('0' + date.getDate()).slice(-2)
        ].join(separator);
    };
    DateTimeHelper.isDateObject = function (date) {
        return Object.prototype.toString.call(date) === '[object Date]' &&
            date instanceof Date &&
            !isNaN(date === null || date === void 0 ? void 0 : date.getTime());
    };
    return DateTimeHelper;
}());
exports.DateTimeHelper = DateTimeHelper;
