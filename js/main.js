var partials = {
    /**
     * Newline can be start of text, or div, or br
     */
    newline: '((?:<div>)|(?:<\/?br>)|^)',

    /**
     * Sometimes nbsp was included
     */
    space: '(?: |(?:&nbsp;))'
};

var lighter = {

    target: {}, queue: 0,

    // Ignored keys
    ignored: [13, 37, 38, 39, 40],

    // timeout before parsing text
    timeout: 300,

    match: {
        heading: new Rule({
            elClass: 'heading',
            regex: new RegExp(
                partials.newline + '(#{1,6}' + partials.space + '[^<]*)', 'g'
            ),
            subregex: /(#{1,6})/g,
            fn: function(full, newline, content) {
                var headingLevel;
                content = content.replace(this.subregex, function(mt) {
                    headingLevel = mt.length;
                    return util.wrapMark(mt);
                });
                return newline + util.wrap(this.elClass + headingLevel, content);
            }
        }),

        bold: new Rule({
            elClass: 'bold',
            regex: new RegExp(
                '(?:__(?!' + partials.space + ').+?__)' +
                '|(?:\\*\\*(?!' + partials.space + ').+?\\*\\*)', 'g'
            ),
            subregex: /(?:\*\*)|(?:__)/g
        }),

        italic: new Rule({
            elClass: 'italic',
            regex: new RegExp(
                '(?:[^_]_(?!_| |(?:&nbsp;)).+?[^_]_[^_])|' +
                '(?:[^\\*]\\*(?!\\*| |(?:&nbsp;)).+?[^\\*]\\*[^\\*])', 'g'
            ),
            subregex: /[\*_]/g,
            // lookbehing is missing :(
            fn: function (full) {
                var length = full.length - 2;
                return full[0] + Object.getPrototypeOf(this).fn.call(this, full.substr(1, length)) + full.substr(-1);
            }
        }),

        list: new Rule({
            elClass: 'list',
            regex: new RegExp(partials.newline+'([\\+\\-\\*]'+partials.space + ')', 'g'),
            fn: function(full, newline, content) {
                return newline + Object.getPrototypeOf(this).fn.call(this, content);
            }
        }),

        quote: new Rule({
            elClass: 'quote',
            regex: new RegExp(partials.newline+'(&gt;'+partials.space+'.+)', 'g'),
            subregex: /&gt;/,
            fn: function(full, newline, content) {
                return newline + Object.getPrototypeOf(this).fn.call(this, content);
            }
        })
    },

    init: function(target) {
        this.target = target;
        this.bindEvents();

        this.light();
    },

    bindEvents: function() {
        $(this.target).keyup(this.keyUp.bind(this));
    },

    /*******************************************
     * Event Listeners
     *******************************************/

    keyUp: function(event) {

        clearInterval(this.queue);

        if (this.ignored.indexOf(event.keyCode) === -1) {
            setTimeout(function () {
                selection.save();

                this.clean();
                this.light();

                selection.restore();
            }.bind(this), this.timeout);
        }
    },

    /*******************************************
     * Parsing
     *******************************************/

    /**
     * Exeute function on content of innerHTML
     * @param  {function} fnc function to execute
     */
    _execute: function(fnc) {
        this.target.innerHTML = fnc.call(this, this.target.innerHTML);
    },

    light: function() {
        this._execute(this.addAllMarks);
    },
    clean: function () {
        this._execute(this.removeMarks);
    },


    /**
     * Add marks to content
     * @param  {string} content Text to parse
     * @return {string}         Text with applied highlighting
     */
    addAllMarks: function(content) {

        for (var match in this.match) {
            var cur = this.match[match];
            content = this.addMark(content, cur);
        }

        return content;
    },

    /**
     * Add mark for one type eg. heading, bold
     * @param  {string} content Do it on this string
     * @param  {Rule}   match   Rule to use
     * @return {string}
     */
    addMark: function(content, match) {
        return content.replace(match.regex, match.fn.bind(match));
    },

    /**
     * Remove all the marks from text
     * @param  {string} content Text to polish
     * @return {string}         Cleaned text
     */
    removeMarks: function(content) {
        return content.replace(/<\/?spa.+?>/g, '');
    }

};