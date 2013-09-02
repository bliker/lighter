describe 'Testing markdown block elements', ->


    mock = blocks: [], index: 0
    # call a parser with shimmed object
    run = (parser) ->
        markdown.parsers[parser].call mock

    describe 'AtxHeadings', ->

        it 'Simple', ->
            mock.blocks[0] = '# Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type).toBe(1)

        it 'Long', ->
            mock.blocks[0] = '###### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type).toBe(6)

            mock.blocks[0] = '####### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type).toBe(6)

        it 'Without space', ->
            mock.blocks[0] = '###Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeTruthy()
            expect(result.type).toBe(3)

        it 'With indentation', ->
            mock.blocks[0] = ' ### Hello'
            result = run('atxheading')
            expect(result instanceof LAtxHeading).toBeFalsy()

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

    describe 'Empty', ->

        it 'with space', ->
            mock.blocks[0] = ' '
            result = run('empty')
            expect(result instanceof LEmpty).toBeTruthy()

        it 'with some character', ->
            mock.blocks[0] = 's'
            result = run('empty')
            expect(result instanceof LEmpty).toBeFalsy()
