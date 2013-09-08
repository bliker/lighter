describe 'Testing markdown block elements', ->

    mock = blocks: [], index: 0
    # call a parser with shimmed object
    run = (parser) ->
        MarkdownBlockParser.prototype.parsers[parser].call mock

    beforeEach ->
        mock.blocks = []
        mock.index = 0

    describe 'AtxHeadings', ->

        it 'simple', ->
            mock.blocks[0] = '# Hello'
            result = run('atxheading')
            expect(result instanceof Markdown.AtxHeading).toBeTruthy()
            expect(result.type()).toBe(1)

        it 'long', ->
            mock.blocks[0] = '###### Hello'
            result = run('atxheading')
            expect(result instanceof Markdown.AtxHeading).toBeTruthy()
            expect(result.type()).toBe(6)

            mock.blocks[0] = '####### Hello'
            result = run('atxheading')
            expect(result instanceof Markdown.AtxHeading).toBeTruthy()
            expect(result.type()).toBe(6)

        it 'without space', ->
            mock.blocks[0] = '###Hello'
            result = run('atxheading')
            expect(result instanceof Markdown.AtxHeading).toBeTruthy()
            expect(result.type()).toBe(3)

        it 'with indentation', ->
            mock.blocks[0] = ' ### Hello'
            result = run('atxheading')
            expect(result instanceof Markdown.AtxHeading).toBeFalsy()

    describe 'Setext Headings', ->

        it 'simple h1', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '======'
            result = run('setextheading')
            expect(result instanceof Markdown.SetextHeading).toBeTruthy()
            expect(result.type()).toBe(1);

        it 'simple h2', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '-----'
            result = run('setextheading')
            expect(result instanceof Markdown.SetextHeading).toBeTruthy()
            expect(result.type()).toBe(2);

        it 'with space after', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '-----   '
            result = run('setextheading')
            expect(result instanceof Markdown.SetextHeading).toBeTruthy()
            expect(result.type()).toBe(2);

        it 'without next line', ->
            mock.blocks[0] = 'Hello'
            result = run('setextheading')
            expect(result instanceof Markdown.SetextHeading).toBeFalsy()



    describe 'Unordered list', ->

        it 'various characters', ->
            mock.can_be_nested = -> false

            mock.blocks[0] = '- Hello'
            result = run('ulist')
            expect(result instanceof Markdown.UnorderedList).toBeTruthy()

            mock.blocks[0] = '* Hello'
            result = run('ulist')
            expect(result instanceof Markdown.UnorderedList).toBeTruthy()

            mock.blocks[0] = '+ Hello'
            result = run('ulist')
            expect(result instanceof Markdown.UnorderedList).toBeTruthy()

        it 'without space', ->
            mock.blocks[0] = '+Hello'
            result = run('ulist')
            expect(result instanceof Markdown.UnorderedList).toBeFalsy()

    describe 'Ordered Lists', ->

        it 'with number', ->
            mock.blocks[0] = '1. Hello'
            result = run('olist')
            expect(result instanceof Markdown.OrderedList).toBeTruthy()

        it 'without dot', ->
            mock.blocks[0] = '1 Hello'
            result = run('olist')
            expect(result instanceof Markdown.OrderedList).toBeFalsy()

    describe 'Quote', ->

        it 'as usual', ->
            mock.blocks[0] = '> Hello'
            result = run('quote')
            expect(result instanceof Markdown.Quote).toBeTruthy()

        it 'without space', ->
            mock.blocks[0] = '>Hello'
            result = run('quote')
            expect(result instanceof Markdown.Quote).toBeFalsy()
