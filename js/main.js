var lighter = {

    target: {}, queue: 0,

    // Ignored keys
    ignored: [13, 37, 38, 39, 40],

    // timeout before parsing text
    timeout: 300,

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