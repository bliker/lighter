describe('Testing markdown block elements', function () {

    // shiming variables like a baos
    var that = {
        blocks: [],
        index: 0
    };

    var run_parser = function (parser) {
        // call a parser with shimmed object
        return markdown.parsers[parser].call(that);
    }

    it('headings', function() {
        that.blocks[0] = '## Heading';
        var result = run_parser('atxheading');

    });

    it('unordered lists', function() {

    });


    it('ordered lists', function() {

    });

    it('nested lists', function() {

    });


    it('quotes', function() {

    });

    it('headings', function() {

    });

    it('headings', function() {

    });
});