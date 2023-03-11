"use strict";
exports.__esModule = true;
exports.StringHelper = void 0;
var StringHelper = /** @class */ (function () {
    function StringHelper() {
    }
    StringHelper.escapeRegExp = function (text) {
        if (typeof text !== 'string') {
            return text;
        }
        return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    };
    return StringHelper;
}());
exports.StringHelper = StringHelper;
