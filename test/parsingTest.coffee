describe 'Testing markdown block elements', ->

  # shiming variables like a baos
  shim = blocks: [], index: 0
  shim.can_be_nested = markdown.can_be_nested
  shim.can_be_nested = markdown.is_whitespace

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
    shim.blocks[0] = '1. hej'
    shim.blocks[0] = '  2. hej'
    result = run_parser('olist')
    expect(result.type).toBe('ol')

  it 'quotes', ->

  it 'headings', ->

  it 'headings', ->

