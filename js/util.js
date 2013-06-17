/**
 * Utils, this object is just collection of functions
 */
util = {};
util.wrap = function (cls, text) {
    return '<span class="lighter '+cls+'">'+text+'</span>';
};

util.wrapMark = function (subresult) {
    return util.wrap('mark', subresult);
};