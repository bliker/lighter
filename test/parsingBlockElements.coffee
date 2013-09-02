describe 'Testing markdown block elements', ->

    # shiming variables like a baos
    shim = blocks: [], index: 0
    shim.can_be_nested = markdown.can_be_nested
    shim.is_whitespace = markdown.is_whitespace
    shim.is_codeblock_seq = markdown.is_codeblock_seq
    shim.is_type = markdown.is_type

    run_parser = (parser) ->
        # call a parser with shimmed object
        markdown.parsers[parser].call shim

    it 'headings', ->
        shim.blocks[0] = '## Heading'
        result = run_parser('atxheading')
        expect(result.type).toBe('h2')

        shim.blocks[0] = '# Heading'
        result = run_parser('atxheading')
        expect(result.type).toBe('h1')

        shim.blocks[0] = '####### Heading'
        result = run_parser('atxheading')
        expect(result.type).toBe('h6')

    it 'unordered lists', ->
        shim.blocks[0] = '- Hello'
        result = run_parser('ulist')
        expect(result.type).toBe('ul')

        shim.blocks[0] = '* Hello'
        result = run_parser('ulist')
        expect(result.type).toBe('ul')

    it 'ordered lists', ->
        shim.blocks[0] = '1. Hello'
        result = run_parser('olist')
        expect(result.type).toBe('ol')

    it 'nested lists', ->
        # Do not really want to fake all the parsing for no reason
        shim.can_be_nested = -> true
        shim.blocks[0] = '  2. hej'
        result = run_parser('olist')
        expect(result.type).toBe('ol')

        shim.blocks[0] = '  - hej'
        result = run_parser('ulist')
        expect(result.type).toBe('ul')

        shim.can_be_nested = -> false
        shim.blocks[0] = '  2. hej'
        result = run_parser('olist')
        expect(result).toBe(false)

        shim.blocks[0] = '  - hej'
        result = run_parser('ulist')
        expect(result).toBe(false)

    it 'quotes', ->
        shim.blocks[0] = '> bananas'
        result = run_parser('quote')
        expect(result.type).toBe('quote')

        shim.blocks[0] = '>bananas'
        result = run_parser('quote')
        expect(result).toBe(false)

    it 'codeblock', ->
        shim.is_type = -> true
        shim.blocks[0] = '    bananas'
        result = run_parser('codeblock')
        expect(result.type).toBe('codeblock')

    it 'codeblockg', ->
        shim.blocks[0] = '```'
        shim.blocks[1] = 'code Stuff'
        shim.blocks[2] = '```'

        result = run_parser('codeblockg')
        expect(result.type).toBe('codeblockg')