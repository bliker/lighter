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

        parsed_blocks = @parseBlocks()

    parseBlocks: ->
        current_block = @blocks[@index];
        console.log('Parsing block:', current_block);
        block_parsed = false
        for k, parser of @parsers
            parsed = parser.apply(this)

            # Save parsed block to array and leave the parsing loop
            if parsed
                current_block = parsed
                block_parsed = true
                break

        ## Not parsed by regular stuff, must be paragrpah
        if not block_parsed
            current_block =
                type: 'para'
                data: [new MNode(current_block, 'content')]

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
            return false if current[0] isnt '#'

            i = 1
            i++ while current[i] is '#' and i < 6

            parsed =
                type: 'h' + i
                data: [
                    new MNode(current.substr(0, i), 'mark')
                    new MNode(current.substr(i), 'content')
                ]

        ulist: ->
            current = @blocks[@index]

            # Can be nested so we can ignore whitespace
            i = 0
            if @can_be_nested(@blocks[@index-1])
                i++ while @is_whitespace(current[i])

            valid_char = ['*', '-', '+'].has(current[i])
            space_after = current[i+1] is " ";

            if not valid_char or not space_after
                return false

            parsed =
                type: 'ul'
                data: [
                    new MNode(current.substr(0, i), 'mark')
                    new MNode(current.substr(i), 'content')
                ]


        olist: ->
            current = @blocks[@index]

            i = 0
            if @can_be_nested(@blocks[@index-1])
                i++ while @is_whitespace(current[i])

            i++ while Number(current[i])

            numeric = i > 0
            with_dot_after = current[i] is '.'

            return false if not numeric or not with_dot_after

            parsed =
                type: 'ol'
                data: [
                    new MNode(current.substr(0, i+1), 'mark')
                    new MNode(current.substr(i+1), 'content')
                ]

        quote: ->
            current = @blocks[@index]

            return false if (current[0] isnt '>') or (current[1] isnt " ")
            parse =
                type: 'quote'
                data: [
                    new MNode(current[0], 'mark')
                    new MNode(current.substr(1), 'content')
                ]

        empty: ->
            current = @blocks[@index]

            i = 0
            i++ while current[i] and @is_whitespace(current[i])

            # There is less whitespace than acutal characters
            return false if (i-1) isnt current.length

            parsed =
                type: 'empty'
                data: new MNode(current, 'content')

        codeblock: (blocks, index) ->
            return false


    # has ul or ol before?
    can_be_nested: (prev) ->
        return false unless prev
        prev and ['ol', 'ul'].has(prev.type)

    # check is character is indeed a whitespace
    is_whitespace: (char) ->
        [" ", "\t"].has(char)

    is_empty: (block) ->



class MNode
    constructor: (content, type) ->
        @content = content
        @type = type