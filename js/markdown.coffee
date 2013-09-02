window.markdown =

    parse: (text) ->
        blocks = text.split('\n')
        return text if blocks.length == 0

        # tracks where in parsed file are we
        # No point of passing it around
        @blocks = blocks
        @index  = 0

        json_blocks = @createJson()
        html_blocks = @createHtml()

    # Create Json form markdown text
    createJson: ->
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

    createHtml: ->

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

            valid_char = ['*', '-', '+'].indexOf(current[i]) > -1
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

            # Not bug, using the same i to count refrecence for mark
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
                data: [new MNode(current, 'content')]

        # The indented codeblock
        codeblock: ->
            current = @blocks[@index]
            prev = @blocks[@index-1]

            # There must be a empty line before or code
            not_empty = not @is_type(prev, 'empty')
            not_codeblock = not @is_type(prev, 'codeblock')
            return false if not_empty or not_codeblock

            i = 0
            i++ while current[i] is ' '
            return false if i < 4 and current[0] isnt '\t'

            parsed =
                type: 'codeblock'
                data: [new MNode(current, 'content')]

        codeblockg: ->
            current = @blocks[@index]

            # Backtics have to be lonely
            return false if not open_backticks = @is_codeblock_seq(current)

            @blocks[@index] =
                type: 'codeblockg'
                data: [new MNode(current, 'mark')]

            # Non sandard block skipping in here
            @index++
            while @blocks[@index] and not close_backticks = @is_codeblock_seq(@blocks[@index])
                @blocks[@index] =
                    type: 'codeblockg'
                    data: [new MNode(@blocks[@index], 'content')]
                @index++

            # Last block has to be returned istead of assgined
            parsed =
                type: 'codeblockg'
                data: [new MNode(@blocks[@index], 'mark')]



    # has ul or ol before?
    can_be_nested: (prev) ->
        return false unless prev
        prev and ['ol', 'ul'].indexOf(prev.type) > -1

    # check is character is indeed a whitespace
    is_whitespace: (char) ->
        [" ", "\t"].indexOf(char) > -1

    is_type: (block, type) ->
        return false unless block
        block.type is type

    # Shitty old nap wizzing thru the air
    is_codeblock_seq: (block) ->
        return false unless block
        i = 0;
        i++ while block[i] is '`'

        i < 3 or i isnt block.length


class MNode
    constructor: (content, type) ->
        @content = content
        @type = type