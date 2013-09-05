describe 'Testing markdown block elements', ->


    mock = blocks: [], index: 0
    # call a parser with shimmed object
    run = (parser) ->
        markdown.parsers[parser].call mock

    beforeEach ->
        mock.blocks = []
        mock.index = 0

    describe 'AtxHeadings', ->

        it 'simple', ->
            mock.blocks[0] = '# Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type()).toBe(1)

        it 'long', ->
            mock.blocks[0] = '###### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type()).toBe(6)

            mock.blocks[0] = '####### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type()).toBe(6)

        it 'without space', ->
            mock.blocks[0] = '###Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type()).toBe(3)

        it 'with indentation', ->
            mock.blocks[0] = ' ### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeFalsy()

    describe 'Setext Headings', ->

        it 'simple h1', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '======'
            result = run('setextheading')
            expect(result instanceof LSetextHeading).toBeTruthy()
            expect(result.type()).toBe(1);

        it 'simple h2', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '-----'
            result = run('setextheading')
            expect(result instanceof LSetextHeading).toBeTruthy()
            expect(result.type()).toBe(2);

        it 'with space after', ->
            mock.blocks[0] = 'Hello'
            mock.blocks[1] = '-----   '
            result = run('setextheading')
            expect(result instanceof LSetextHeading).toBeTruthy()
            expect(result.type()).toBe(2);

    describe 'Unordered list', ->

        it 'various characters', ->
            mock.can_be_nested = -> false

            mock.blocks[0] = '- Hello'
            result = run('ulist')
            expect(result instanceof LUnorderedList).toBeTruthy()

            mock.blocks[0] = '* Hello'
            result = run('ulist')
            expect(result instanceof LUnorderedList).toBeTruthy()

            mock.blocks[0] = '+ Hello'
            result = run('ulist')
            expect(result instanceof LUnorderedList).toBeTruthy()

        it 'without space', ->
            mock.blocks[0] = '+Hello'
            result = run('ulist')
            expect(result instanceof LUnorderedList).toBeFalsy()

    describe 'Ordered Lists', ->

        it 'with number', ->
            mock.blocks[0] = '1. Hello'
            result = run('olist')
            expect(result instanceof LOrderedList).toBeTruthy()

        it 'without dot', ->
            mock.blocks[0] = '1 Hello'
            result = run('olist')
            expect(result instanceof LOrderedList).toBeFalsy()

    describe 'Quote', ->

        it 'as usual', ->
            mock.blocks[0] = '> Hello'
            result = run('quote')
            expect(result instanceof LQuote).toBeTruthy()

        it 'without space', ->
            mock.blocks[0] = '>Hello'
            result = run('quote')
            expect(result instanceof LQuote).toBeFalsy()

    describe 'Empty', ->

        it 'with space', ->
            mock.blocks[0] = ' '
            result = run('empty')
            expect(result instanceof LEmpty).toBeTruthy()

        it 'with some character', ->
            mock.blocks[0] = 's'
            result = run('empty')
            expect(result instanceof LEmpty).toBeFalsy()
