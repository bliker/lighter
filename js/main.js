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

};