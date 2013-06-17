describe('Parsing text and adding marks', function() {
    it('for headings only on the new line', function() {
        var string = '<div>## Heading like this</div><div>but not like ## Thisd</div>';
        var replaced = lighter.addMark(string, lighter.match.heading);
        expect(replaced).toBe('<div><span class="lighter heading2"><span class="lighter mark">##</span> Heading like this</span></div><div>but not like ## Thisd</div>');
    });

    describe('with different heading numbers', function() {
        var host = document.createElement('div');
        var string = '<div># Heading one</div><div>## Heading two</div><div>### Heading three</div>'+
                     '<div>#### Heading four</div><div>##### Heading five</div><div>###### Heading six</div>';

        var replaced = lighter.addMark(string, lighter.match.heading);

        host.innerHTML = replaced;

        it('for h1', function() {
            expect(host.children[0].firstChild.classList.contains('heading1')).toBeTruthy();
        });

        it('for h2', function() {
            expect(host.children[1].firstChild.classList.contains('heading2')).toBeTruthy();
        });

        it('for h3', function() {
            expect(host.children[2].firstChild.classList.contains('heading3')).toBeTruthy();
        });

        it('for h4', function() {
            expect(host.children[3].firstChild.classList.contains('heading4')).toBeTruthy();
        });

        it('for h5', function() {
            expect(host.children[4].firstChild.classList.contains('heading5')).toBeTruthy();
        });

        it('for h6', function() {
            expect(host.children[5].firstChild.classList.contains('heading6')).toBeTruthy();
        });
    });

    it('for quotes', function() {
        var string = '<div>&gt; Quote</div>';
        var replaced = lighter.addMark(string, lighter.match.quote);
        expect(replaced).toBe('<div><span class="lighter quote"><span class="lighter mark">&gt;</span> Quote</div></span>');
    });
});