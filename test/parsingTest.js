describe('Testing markdown block elements', function () {
    it('headings', function () {
        parsed = markdown.parse('## hej');
        expect(parsed[0].type).toBe('h2');

        parsed = markdown.parse('####### hej');
        expect(parsed[0].type).toBe('h6');

        parsed = markdown.parse('### hej');
        expect(parsed[0].type).toBe('h3');

        // Add not passing for paragraph
    });

    it('unordered lists', function () {
        parsed = markdown.parse('- hej');
        expect(parsed[0].type).toBe('ul');

        parsed = markdown.parse('+ hej');
        expect(parsed[0].type).toBe('ul');

        // Add not passing for paragraph
    })

    it('unorderd nested lists', function () {
        parsed = markdown.parse("- hej\n  - hej");
        expect(parsed[0].type).toBe('ul');
        expect(parsed[1].type).toBe('ul');

        parsed = markdown.parse("hej\n  - hej");
        // talking about not passin
    })

    it('orderd lists', function () {
        parsed = markdown.parse('1. hej');
        expect(parsed[0].type).toBe('ol');
    })

    it('orderd nested lists', function () {
        parsed = markdown.parse("1. hej \n  3.hej");
        expect(parsed[0].type).toBe('ol');
        expect(parsed[1].type).toBe('ol');
        console.log(parsed);

        parsed = markdown.parse("hej \n  3.hej");
    })

    it('quotes', function () {
        // Simple interpeetation
        parsed = markdown.parse('> hej');
        expect(parsed[0].type).toBe('quote');
    })


});