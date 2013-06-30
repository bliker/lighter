describe('Parsing text and adding marks', function() {

    var host = document.createElement('div');

    it('for headings only on the new line', function() {
        var string = '<div>## Heading like this</div><div>but not like ## Thisd</div>';
        var replaced = lighter.addMark(string, lighter.match.heading);

        host.innerHTML = replaced;

        // Marks for first child
        expect(host.children[0].getElementsByClassName('heading2').length).toBe(1);
        expect(host.children[0].getElementsByClassName('mark').length).toBe(1);

        // Nothing for second one
        expect(host.children[1].getElementsByClassName('mark').length).toBe(0);
    });

    describe('with different heading numbers', function() {

        var headingHost = document.createElement('div');

        var string = '<div># Heading one</div>'+
                     '<div>## Heading two</div>' +
                     '<div>### Heading three</div>' +
                     '<div>#### Heading four</div>' +
                     '<div>##### Heading five</div>' +
                     '<div>###### Heading six</div>';

        var replaced = lighter.addMark(string, lighter.match.heading);

        headingHost.innerHTML = replaced;

        it('for h1', function() {
            expect(headingHost.children[0].firstChild.classList.contains('heading1')).toBeTruthy();
        });

        it('for h2', function() {
            expect(headingHost.children[1].firstChild.classList.contains('heading2')).toBeTruthy();
        });

        it('for h3', function() {
            expect(headingHost.children[2].firstChild.classList.contains('heading3')).toBeTruthy();
        });

        it('for h4', function() {
            expect(headingHost.children[3].firstChild.classList.contains('heading4')).toBeTruthy();
        });

        it('for h5', function() {
            expect(headingHost.children[4].firstChild.classList.contains('heading5')).toBeTruthy();
        });

        it('for h6', function() {
            expect(headingHost.children[5].firstChild.classList.contains('heading6')).toBeTruthy();
        });
    });

    it('for quotes', function() {
        var string = '<div>&gt; Quote</div>';
        var replaced = lighter.addMark(string, lighter.match.quote);

        host.innerHTML = replaced;

        expect(host.getElementsByClassName('quote').length).toBe(1);
        expect(host.getElementsByClassName('mark').length).toBe(1);

    });

    it('for list', function() {
        var string = '<div>- List</div>' +
                     '<div>+ List</div>' +
                     '<div>* List</div>';

        var replaced = lighter.addMark(string, lighter.match.list);

        host.innerHTML = replaced;

        expect(host.getElementsByClassName('list').length).toBe(3);
    });

    it('for bold', function() {
        var string = '__Bold__ Not Bold __ Not Bold __';
        var replaced = lighter.addMark(string, lighter.match.bold);

        host.innerHTML = replaced;

        expect(host.children[0].classList.contains('bold')).toBeTruthy();
        expect(host.getElementsByClassName('bold').length).toBe(1);
    });

    it('for bold with asterks', function() {
        var string = '**Bold** Not Bold ** Not Bold **';
        var replaced = lighter.addMark(string, lighter.match.bold);

        host.innerHTML = replaced;

        expect(host.children[0].classList.contains('bold')).toBeTruthy();
        expect(host.getElementsByClassName('bold').length).toBe(1);
    });

    it('for italic', function() {
        var string = 'Stuff _Italic_ Not italic _ Italic_ ';
        var replaced = lighter.addMark(string, lighter.match.italic);

        host.innerHTML = replaced;

        console.log(host);

        expect(host.children[0].classList.contains('italic')).toBeTruthy();
        expect(host.getElementsByClassName('italic').length).toBe(1);
    });

    it('for italic with asterks', function() {
        var string = 'Stuff *Italic* Not italic * Italic* ';
        var replaced = lighter.addMark(string, lighter.match.italic);

        host.innerHTML = replaced;

        expect(host.children[0].classList.contains('italic')).toBeTruthy();
        expect(host.getElementsByClassName('italic').length).toBe(1);
    });

    it('for inline code', function() {
        var string = 'Ima text Ima text `String::shift()` stuff';
        var replaced = lighter.addMark(string, lighter.match.inlineCode);

        host.innerHTML = replaced;

        expect(host.getElementsByClassName('inlineCode').length).toBe(1);
    });

});