# Keeping this private
class MarkdownBlockParser

    constructor: (text) ->
        return new Markdown.Empty(content: text) if not text or text.trim().length is 0

        blocks = text.split('\n')
        # tracks where in parsed file are we
        # No point of passing it around
        @blocks = blocks
        @index  = 0

        return @loop()

    loop: ->
        @parse()
        @index++
        # recrusiveluy call for parser
        # If we are on the end return the parsed stuff
        if @blocks.length > @index then @loop() else @blocks

    parse: ->
        current = @blocks[@index];
        block_parsed = false

        if current.trim().length is 0
            @blocks[@index] = new Markdown.Empty({content: current})
            return

        for k, parser of @parsers
            parsed = parser.apply(this)

            # Save parsed block to array and leave the parsing loop
            if parsed
                @blocks[@index] = parsed
                block_parsed = true
                console.log('Parsed block', current);
                break

        # Not parsed by regular stuff, must be paragrpah
        if not block_parsed
            @blocks[@index] = new Markdown.Paragraph({content: current})


    # Block level parsers
    parsers:
        atxheading: ->
            current = @blocks[@index]
            return false if current[0] isnt '#'

            i = 1
            i++ while current[i] is '#' and i < 6

            # mark + content
            new Markdown.AtxHeading(
                mark: current.substr(0, i),
                content: current.substr(i)
                type: i)

        setextheading: ->
            current = @blocks[@index]

            next = @blocks[@index+1]
            return false if not next

            char = ['=', '-'].indexOf(next[0]);
            return false if not char < 0

            i = 1
            # Check if first character is there until the end of line
            i++ while next[i] is next[0]
            return false if i isnt next.trim().length

            @blocks[@index] = new Markdown.SetextHeading(
                content: current,
                type: char + 1)

            # Blockskipping
            @index++
            new Markdown.SetextHeading(
                mark: next
                type: char + 1)

        ulist: ->
            current = @blocks[@index]

            # Can be nested so we can ignore whitespace
            i = 0
            if @can_be_nested(@blocks[@index-1])
                i++ while @is_whitespace(current[i])

            valid_char = current[i] in ['*', '-', '+']
            space_after = current[i+1] and current[i+1] is " "
            return false if not valid_char or not space_after

            new Markdown.UnorderedList(
                mark: current.substr(0, i)
                content: current.substr(i))

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

            new Markdown.OrderedList(
                mark: current.substr(0, i+1)
                content: current.substr(i+1))

        quote: ->
            current = @blocks[@index]

            return false if (current[0] isnt '>') or (current[1] isnt " ")
            # Nested quotes not supported yet!

            new Markdown.Quote(
                mark: current[0]
                content: current.substr(1))

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

            new Markdown.Codeblock(content: current)

        codeblockg: ->
            current = @blocks[@index]

            return false if not open_backticks = @is_codeblock_seq(current)
            @blocks[@index] = new Markdown.GithubCodeblock(mark: current)

            # Non sandard block skipping in here
            # I miss pointers here
            @index++
            while @blocks[@index] and not close_backticks = @is_codeblock_seq(@blocks[@index])
                @blocks[@index] =  new Markdown.GithubCodeblock(content: @blocks[@index])
                @index++

            # Last block has to be returned instead of assgined
            new Markdown.GithubCodeblock(mark: @blocks[@index])

    ############
    # Helper methods in object root for convinience
    ##########

    # has ul or ol before?
    can_be_nested: (prev) ->
        return false unless prev
        prev and prev.type in ['ol', 'ul']

    # check is character is indeed a whitespace
    is_whitespace: (char) ->
        [
            '\u0020' # space
            '\u00A0' # non breaking space
            '\u0009' # tab
        ].indexOf(char) > -1

    is_type: (block, type) ->
        return false unless block
        block.type is type

    # Shitty old nap wizzing thru the air
    is_codeblock_seq: (block) ->
        return false unless block
        i = 0;
        i++ while block[i] is '`'


        # Backtics have to be lonely
        i > 2 and i is block.length

window.markdown =

    toJson: (text) -> new MarkdownBlockParser(text)

    toHtml: (text) ->
        parsed_html = ''
        parsed_json = @toJson(text)
        for block in parsed_json
            parsed_html += block.toHtml() + '</br>'
        parsed_html
