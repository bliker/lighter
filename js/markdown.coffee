Array::has = (key) ->
  @indexOf(key) > -1

window.markdown =

    parse: (text) ->
        blocks = text.split('\n')
        return text if blocks.length == 0

        # tracks where in parsed file are we
        # No point of passing it around
        @blocks = blocks
        @index  = 0

        parsed_blocks = @parseBlocks

    parseBlocks: ->
        console.log('Parsing block:', @blocks[@index]);
        block_parsed = false
        for k, parser of @parsers
            parsed = parser.apply(this)

            # Save parsed block to array and leave the parsing loop
            if parsed
                @blocks[@index] = parsed
                block_parsed = true
                break

        ## Not parsed by regular
        # unless block_parsed

        # Index
        @index++
        if @blocks.length > @index
            # recrusive call for parsing
            @parseBlocks
        else
            # All blocks are parsed
            return @blocks

    parsers:
        atxheading: ->
            current = @blocks[@index]
            console.log(current)

            return false if current[0] isnt '#'

            i = 1
            i++ while current[i] is '#' and i < 6

            parsed =
                type: 'h' + i
                data: [
                    new MNode(current.substr(0, i), 'mark')
                    new MNode(current.substr(i), 'content')
                ]


    # has ul or ol before?
    can_be_nested: (prev) ->
        prev and ['ol', 'ul'].has(prev.type)

    # check is character is indeed a whitespace
    is_whitespace: (char) ->
        [" ", "\t"].has(char)

    is_empty: (block) ->



class MNode
    constructor: (content, type) ->
        @content = content
        @type = type