"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
exports.__esModule = true;
exports.ChronoHelper = void 0;
var chrono = __importStar(require("chrono-node"));
var DateTimeHelper_1 = require("./DateTimeHelper");
var StringHelper_1 = require("./StringHelper");
var customParsers = {
    tod: {
        pattern: function () { return /\btod\b/i; },
        extract: function () {
            var today = DateTimeHelper_1.DateTimeHelper.today();
            return {
                day: today.getDate(),
                month: today.getMonth() + 1,
                year: today.getFullYear()
            };
        }
    },
    toda: {
        pattern: function () { return /\btoda\b/i; },
        extract: function () {
            var today = DateTimeHelper_1.DateTimeHelper.today();
            return {
                day: today.getDate(),
                month: today.getMonth() + 1,
                year: today.getFullYear()
            };
        }
    },
    tom: {
        pattern: function () { return /\btom\b/i; },
        extract: function () {
            var tomorrow = DateTimeHelper_1.DateTimeHelper.tomorrow();
            return {
                day: tomorrow.getDate(),
                month: tomorrow.getMonth() + 1,
                year: tomorrow.getFullYear()
            };
        }
    },
    tmrw: {
        pattern: function () { return /\btmrw\b/i; },
        extract: function () {
            var tomorrow = DateTimeHelper_1.DateTimeHelper.tomorrow();
            return {
                day: tomorrow.getDate(),
                month: tomorrow.getMonth() + 1,
                year: tomorrow.getFullYear()
            };
        }
    },
    tmw: {
        pattern: function () { return /\btmw\b/i; },
        extract: function () {
            var tomorrow = DateTimeHelper_1.DateTimeHelper.tomorrow();
            return {
                day: tomorrow.getDate(),
                month: tomorrow.getMonth() + 1,
                year: tomorrow.getFullYear()
            };
        }
    },
    tmr: {
        pattern: function () { return /\btmr\b/i; },
        extract: function () {
            var tomorrow = DateTimeHelper_1.DateTimeHelper.tomorrow();
            return {
                day: tomorrow.getDate(),
                month: tomorrow.getMonth() + 1,
                year: tomorrow.getFullYear()
            };
        }
    },
    addMinutes: {
        pattern: function () { return /\b(\d+)(\s?)(m)\b/i; },
        extract: function (context, match) {
            var minutes = parseInt(match[1]);
            if (minutes) {
                var updatedDate = DateTimeHelper_1.DateTimeHelper.addMinutes(context.refDate, minutes);
                return {
                    day: updatedDate.getDate(),
                    month: updatedDate.getMonth() + 1,
                    year: updatedDate.getFullYear(),
                    minute: updatedDate.getMinutes(),
                    hour: updatedDate.getHours()
                };
            }
        }
    }
};
var ChronoHelper = /** @class */ (function () {
    function ChronoHelper() {
    }
    ChronoHelper.extractDateAndText = function (text, options) {
        ChronoHelper.setCustomChrono();
        var forwardFrom = (options === null || options === void 0 ? void 0 : options.forwardFrom) || new Date();
        forwardFrom.setMilliseconds(0);
        ChronoHelper.customChrono.refiners.push({
            refine: function (_, results) {
                results.forEach(function (result) {
                    var _a, _b, _c, _d, _e, _f;
                    var date = result.start.date();
                    // if there's no am/pm we imply if hour is earlier than ref date
                    // we either increase meridiem or bump to next day
                    var impliedHourDifference = forwardFrom.getHours() - ((_c = (_b = (_a = result === null || result === void 0 ? void 0 : result.start) === null || _a === void 0 ? void 0 : _a.get) === null || _b === void 0 ? void 0 : _b.call(_a, 'hour')) !== null && _c !== void 0 ? _c : 0);
                    var hasTime = result.start.isCertain('hour') || result.start.isCertain('minute');
                    if (hasTime && !result.start.isCertain('meridiem') && DateTimeHelper_1.DateTimeHelper.isSameDay(date, forwardFrom)) {
                        if (impliedHourDifference > 0 && impliedHourDifference <= 12) {
                            result.start.assign('meridiem', 1);
                            result.start.assign('hour', ((_f = (_e = (_d = result === null || result === void 0 ? void 0 : result.start) === null || _d === void 0 ? void 0 : _d.get) === null || _e === void 0 ? void 0 : _e.call(_d, 'hour')) !== null && _f !== void 0 ? _f : 0) + 12);
                        }
                        else if (impliedHourDifference > 0) {
                            // eslint-disable-next-line dot-notation
                            result.start.imply('day', result.start['impliedValues'].day + 1);
                        }
                    }
                });
                return results;
            }
        }, {
            refine: function (_, results) {
                results.forEach(function (result) {
                    var _a;
                    // if part of day let's assign time & not just imply it
                    var partOfDayWords = ['now', 'morning', 'noon', 'afternoon', 'evening', 'night'];
                    var partOfDayRegex = new RegExp('\\b' + partOfDayWords.join('\\b|\\b') + '\\b', 'gi');
                    if (result.text) {
                        var matches = result.text.match(partOfDayRegex);
                        if (matches === null || matches === void 0 ? void 0 : matches.length) {
                            var match = matches[0];
                            switch (match) {
                                case 'now': {
                                    var now = new Date();
                                    result.start.assign('hour', now.getHours());
                                    result.start.assign('minute', now.getMinutes());
                                    break;
                                }
                                case 'morning':
                                    result.start.assign('meridiem', 0);
                                    result.start.assign('hour', (_a = options === null || options === void 0 ? void 0 : options.startDayHour) !== null && _a !== void 0 ? _a : 9);
                                    break;
                                case 'noon':
                                    result.start.assign('meridiem', 1);
                                    result.start.assign('hour', 12);
                                    break;
                                case 'afternoon':
                                    result.start.assign('meridiem', 1);
                                    result.start.assign('hour', 14);
                                    break;
                                case 'evening':
                                    result.start.assign('meridiem', 1);
                                    result.start.assign('hour', 18);
                                    break;
                                case 'night':
                                    result.start.assign('meridiem', 1);
                                    result.start.assign('hour', 22);
                                    break;
                            }
                        }
                    }
                });
                return results;
            }
        }, {
            refine: function (context, results) { return (results.filter(function (result) {
                // allow certain month-only (without day) parsing only if previous word is "in"
                var isMonthWithoutDay = result.start && result.start.isCertain('month') && !result.start.isCertain('day');
                if (result.text && isMonthWithoutDay) {
                    var matches = context.text.match(new RegExp("\\w+(?=\\s+".concat(result.text, ")"), 'i'));
                    return !!(matches === null || matches === void 0 ? void 0 : matches.length) && matches[0].toLowerCase() === 'in';
                }
                return true;
            })); }
        }, {
            refine: function (_, results) { return (
            // fix: chrono parses "any" word as "an year" wrongly
            results.filter(function (result) { return !result.text.startsWith('any'); })); }
        }, {
            refine: function (_, results) { return (
            // fix: chrono parses "the day" word as "tomorrow" wrongly
            results.filter(function (result) { return result.text !== 'the day' && result.text !== 'the d'; })); }
        }, {
            refine: function (_, results) {
                var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q, _r;
                // Check if all these conditions are met:
                //   - there are exactly 2 results
                //   - in each result, day is uncertain and one of the months is uncertain
                //   - the two results have a different hour
                // If so, we can assume that the user meant to specify the day and month, and then the hour
                if (results.length !== 2) {
                    return results;
                }
                var bothCertainDay = results.every(function (result) { return result.start.isCertain('day'); });
                var atLeastOneCertainMonth = results.some(function (result) { return result.start.isCertain('month'); });
                var allHourAreEqual = results.every(function (result) { return result.start.get('hour') === results[0].start.get('hour'); });
                if (!bothCertainDay && !atLeastOneCertainMonth && !allHourAreEqual) {
                    // We are unsure of the day and at least one month, and we have different hours
                    // We can assume that the user meant to specify the day and month, and then the hour
                    // Note: assuming the date comes first is not always correct, but it's a good guess
                    results[0].start.assign('day', ((_d = (_c = (_b = (_a = results === null || results === void 0 ? void 0 : results[0]) === null || _a === void 0 ? void 0 : _a.start) === null || _b === void 0 ? void 0 : _b.get) === null || _c === void 0 ? void 0 : _c.call(_b, 'day')) !== null && _d !== void 0 ? _d : 0));
                    results[0].start.assign('hour', ((_h = (_g = (_f = (_e = results === null || results === void 0 ? void 0 : results[1]) === null || _e === void 0 ? void 0 : _e.start) === null || _f === void 0 ? void 0 : _f.get) === null || _g === void 0 ? void 0 : _g.call(_f, 'hour')) !== null && _h !== void 0 ? _h : 0));
                    results[0].start.assign('minute', ((_m = (_l = (_k = (_j = results === null || results === void 0 ? void 0 : results[1]) === null || _j === void 0 ? void 0 : _j.start) === null || _k === void 0 ? void 0 : _k.get) === null || _l === void 0 ? void 0 : _l.call(_k, 'minute')) !== null && _m !== void 0 ? _m : 0));
                    results[1].start.assign('day', ((_r = (_q = (_p = (_o = results === null || results === void 0 ? void 0 : results[0]) === null || _o === void 0 ? void 0 : _o.start) === null || _p === void 0 ? void 0 : _p.get) === null || _q === void 0 ? void 0 : _q.call(_p, 'day')) !== null && _r !== void 0 ? _r : 0));
                }
                return results;
            }
        }, {
            refine: function (_, results) {
                var hasCertainDayMonth = results.some(function (result) { return result.start.isCertain('day') && result.start.isCertain('month'); });
                if (hasCertainDayMonth) {
                    return results;
                }
                var hasCertainHour = results.some(function (result) { return result.start.isCertain('hour'); });
                if (!hasCertainHour) {
                    return results;
                }
                var now = new Date();
                var isToday = results.every(function (result) { return DateTimeHelper_1.DateTimeHelper.isSameDay(result.start.date(), now); });
                if (isToday) {
                    var isInPast = results.every(function (result) { var _a, _b, _c, _d, _e, _f; return ((_c = (_b = (_a = result === null || result === void 0 ? void 0 : result.start) === null || _a === void 0 ? void 0 : _a.get) === null || _b === void 0 ? void 0 : _b.call(_a, 'hour')) !== null && _c !== void 0 ? _c : 0) < now.getHours() || (result.start.get('hour') === now.getHours() && ((_f = (_e = (_d = result === null || result === void 0 ? void 0 : result.start) === null || _d === void 0 ? void 0 : _d.get) === null || _e === void 0 ? void 0 : _e.call(_d, 'minute')) !== null && _f !== void 0 ? _f : 0) < now.getMinutes()); });
                    if (isInPast) {
                        results.forEach(function (result) {
                            var _a, _b, _c;
                            result.start.imply('day', ((_c = (_b = (_a = result === null || result === void 0 ? void 0 : result.start) === null || _a === void 0 ? void 0 : _a.get) === null || _b === void 0 ? void 0 : _b.call(_a, 'day')) !== null && _c !== void 0 ? _c : 0) + 1);
                        });
                    }
                }
                return results;
            }
        });
        var parseResults = ChronoHelper.customChrono.parse(text, forwardFrom, options)
            .sort(function (resultA, resultB) {
            // sort by with "in" word, ascending
            var matchesInResultA = text.match(new RegExp("\\w+(?=\\s+".concat(resultA.text, ")"), 'i'));
            var matchesInResultB = text.match(new RegExp("\\w+(?=\\s+".concat(resultB.text, ")"), 'i'));
            var isMatchinInResultA = !!(matchesInResultA === null || matchesInResultA === void 0 ? void 0 : matchesInResultA.length) && matchesInResultA[0].toLowerCase() === 'in';
            var isMatchinInResultB = !!(matchesInResultB === null || matchesInResultB === void 0 ? void 0 : matchesInResultB.length) && matchesInResultB[0].toLowerCase() === 'in';
            return Math.sign(+isMatchinInResultA - +isMatchinInResultB);
        });
        var parseResult = (parseResults === null || parseResults === void 0 ? void 0 : parseResults.length) ? parseResults[parseResults.length - 1] : null;
        var extractedDateAndText = { date: undefined, textWithoutDate: text };
        if (parseResult) {
            var date = parseResult.start.date();
            var regularExpressionWithTimeToRemove = new RegExp('(^|\\s)(in\\s+)?' + StringHelper_1.StringHelper.escapeRegExp(parseResult.text), 'g');
            var textWithoutDate = text.replace(regularExpressionWithTimeToRemove, '');
            if (parseResult.start.isCertain('weekday') &&
                !parseResult.start.isCertain('day') &&
                !parseResult.start.isCertain('month') &&
                !parseResult.start.isCertain('year') &&
                date.toDateString() === (new Date()).toDateString()) {
                // if the the user wrote "friday 3pm" and today is friday, we want to suggest next friday. Chrono suggests today
                date.setDate(date.getDate() + 7);
            }
            var hasTime = parseResult.start.isCertain('hour') || parseResult.start.isCertain('minute');
            if ((options === null || options === void 0 ? void 0 : options.startFromDateTime) && date < options.startFromDateTime) {
                if ((options === null || options === void 0 ? void 0 : options.startFromDate) && date >= options.startFromDate && !hasTime) {
                    // allow dates without time
                }
                else {
                    return extractedDateAndText;
                }
            }
            extractedDateAndText = {
                date: date,
                textWithoutDate: textWithoutDate,
                hasTime: hasTime,
                hasDate: parseResult.start.isCertain('day') || parseResult.start.isCertain('month') || parseResult.start.isCertain('year') || parseResult.start.isCertain('weekday') || date.toDateString() !== (new Date()).toDateString(),
                hasMeridiem: parseResult.start.isCertain('meridiem'),
                parseResult: parseResult
            };
        }
        return extractedDateAndText;
    };
    ChronoHelper.setCustomChrono = function () {
        if (ChronoHelper.customChrono) {
            return;
        }
        ChronoHelper.customChrono = chrono.casual.clone();
        ChronoHelper.customChrono.parsers.push(customParsers.tod);
        ChronoHelper.customChrono.parsers.push(customParsers.toda);
        ChronoHelper.customChrono.parsers.push(customParsers.tom);
        ChronoHelper.customChrono.parsers.push(customParsers.tmrw);
        ChronoHelper.customChrono.parsers.push(customParsers.tmw);
        ChronoHelper.customChrono.parsers.push(customParsers.tmr);
        ChronoHelper.customChrono.parsers.push(customParsers.addMinutes);
    };
    return ChronoHelper;
}());
exports.ChronoHelper = ChronoHelper;
