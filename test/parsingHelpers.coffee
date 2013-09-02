describe 'Various parsing helepers', ->

    describe 'can_be_nested', ->
        it 'with undefined', -> expect(markdown.can_be_nested(undefined)).toBe(false)
        it 'with ol/ul', ->
            expect(markdown.can_be_nested(type: 'ol')).toBe(true)
            expect(markdown.can_be_nested(type: 'ul')).toBe(true)
        it 'with random stuff', -> expect(markdown.can_be_nested(type: 'h3')).toBe(false)

    describe 'is_whitespace', ->
        it 'with undefined', -> expect(markdown.is_whitespace(undefined)).toBe(false)
        it 'with some character', -> expect(markdown.is_whitespace('s')).toBe(false)
        it 'with some commom whitespace', ->
            expect(markdown.is_whitespace(' ')).toBe(true)
            expect(markdown.is_whitespace('\t')).toBe(true)

    describe 'is_code_block_seq', ->
        it 'with undefined', -> expect(markdown.is_codeblock_seq(undefined)).toBe(false)
        it 'with backticks', -> expect(markdown.is_codeblock_seq('```')).toBe(true)
        it 'with many backticks', -> expect(markdown.is_codeblock_seq('``````')).toBe(true)
        it 'with two backticks', -> expect(markdown.is_codeblock_seq('``')).toBe(false)
        it 'with backticks and character', -> expect(markdown.is_codeblock_seq('`` d')).toBe(false)
