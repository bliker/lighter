/**
 * Keeping regexes here
 */
var Rule = function (settings) {
    var props = ['name', 'regex', 'subregex', 'elClass'];
    for (var prop in props) {
        prop = props[prop];
        this[prop] = settings[prop];
        if (settings.fn) {
            this.fn = settings.fn;
        }
    }
};

Rule.prototype.fn = function(results) {

    var subList;
    if (this.subregex instanceof Array) {
        subList = this.subList;
    } else {
        subList = [this.subregex];
    }

    for (var sub in subList) {
        results = results.replace(subList[sub], util.wrapMark);
    }
    return util.wrap(this.elClass, results);
};
