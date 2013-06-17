var selection =  {

    target: {}, saved: {},

    init: function (target) {
        this.target = target;
    },

    save: function() {
        this.saved = rangy.getSelection().saveCharacterRanges(this.target);
    },

    restore: function() {
        rangy.getSelection().restoreCharacterRanges(this.target, this.saved);
    }
};