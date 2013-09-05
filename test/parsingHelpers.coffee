describe 'Various parsing helepers', ->

    h = lighter_markdown_parser

    describe 'can_be_nested', ->
        it 'with undefined', -> expect(h.can_be_nested(undefined)).toBe(false)
        it 'with ol/ul', ->
            expect(h.can_be_nested(type: 'ol')).toBe(true)
            expect(h.can_be_nested(type: 'ul')).toBe(true)
        it 'with random stuff', -> expect(h.can_be_nested(type: 'h3')).toBe(false)

    describe 'is_whitespace', ->
        it 'with undefined', -> expect(h.is_whitespace(undefined)).toBe(false)
        it 'with some character', -> expect(h.is_whitespace('s')).toBe(false)
        it 'with some commom whitespace', ->
            expect(h.is_whitespace(' ')).toBe(true)
            expect(h.is_whitespace('\t')).toBe(true)

    describe 'is_code_block_seq', ->
        it 'with undefined', -> expect(h.is_codeblock_seq(undefined)).toBe(false)
        it 'with backticks', -> expect(h.is_codeblock_seq('```')).toBe(true)
        it 'with many backticks', -> expect(h.is_codeblock_seq('``````')).toBe(true)
        it 'with two backticks', -> expect(h.is_codeblock_seq('``')).toBe(false)
        it 'with backticks and character', -> expect(h.is_codeblock_seq('`` d')).toBe(false)
