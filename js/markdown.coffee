# Keeping this private
lighter_markdown_parser =

    parse: (text) ->

        if not text or text.trim().length is 0
            return new LEmpty(content: text)

        blocks = text.split('\n')
        # tracks where in parsed file are we
        # No point of passing it around
        @blocks = blocks
        @index  = 0

        @loop()

    loop: ->

        @parse_one()

        @index++
        # recrusiveluy call for parser
        # If we are on the end return the parsed stuff
        if @blocks.length > @index then @loop() else @blocks

    parse_one: ->
        current = @blocks[@index];
        block_parsed = false

        if current.trim().length is 0
            @blocks[@index] = new LEmpty({content: current})
            return

        for k, parser of @block
            parsed = parser.apply(this)

            # Save parsed block to array and leave the parsing loop
            if parsed
                @blocks[@index] = parsed
                block_parsed = true
                console.log('Parsed block', current);
                break

        # Not parsed by regular stuff, must be paragrpah
        if not block_parsed
            @blocks[@index] = new LParagraph({content: current})


    # Block level parsers
    block:
        atxheading: ->
            current = @blocks[@index]
            return false if current[0] isnt '#'

            i = 1
            i++ while current[i] is '#' and i < 6

            # mark + content
            new LAtxHeading(
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

            @blocks[@index] = new LSetextHeading(
                content: current,
                type: char + 1)

            # Blockskipping
            @index++
            new LSetextHeading(
                mark: next
                type: char + 1)

        ulist: ->
            current = @blocks[@index]

            # Can be nested so we can ignore whitespace
            i = 0
            if @can_be_nested(@blocks[@index-1])
                i++ while @is_whitespace(current[i])

            valid_char = ['*', '-', '+'].indexOf(current[i]) > -1
            space_after = current[i+1] is " "

            if not valid_char or not space_after
                return false

            new LUnorderedList(
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

            new LOrderedList(
                mark: current.substr(0, i+1)
                content: current.substr(i+1))

        quote: ->
            current = @blocks[@index]

            return false if (current[0] isnt '>') or (current[1] isnt " ")
            # Nested quotes not supported yet!

            new LQuote(
                mark: current[0]
                content: current.substr(1))

        empty: ->
            current = @blocks[@index]

            return false if current.trim().length
            new LEmpty(content: current)

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

            new LCodeblock(content: current)

        codeblockg: ->
            current = @blocks[@index]

            return false if not open_backticks = @is_codeblock_seq(current)
            @blocks[@index] = new LGithubCodeblock(mark: current)

            # Non sandard block skipping in here
            # I miss pointers here
            @index++
            while @blocks[@index] and not close_backticks = @is_codeblock_seq(@blocks[@index])
                @blocks[@index] =  new LGithubCodeblock(content: @blocks[@index])
                @index++

            # Last block has to be returned instead of assgined
            new LGithubCodeblock(mark: @blocks[@index])



    ############
    # Helper methods in object root for convinience
    ##########

    # has ul or ol before?
    can_be_nested: (prev) ->
        return false unless prev
        prev and ['ol', 'ul'].indexOf(prev.type) > -1

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

############
# Base class
############

class LNode

    constructor: (data) ->
        @_mark = data.mark
        @_content = data.content
        @_type = data.type

    wrap: (content, htmlclass) ->
        htmlclass = @htmlclass unless htmlclass
        '<span class="lighter_'+htmlclass+'">'+content+'</span>'

    mark: -> @wrap(@_mark, 'mark')

    content: -> @_content

    type: -> @_type

############
# Block level classes
############

class LAtxHeading extends LNode
    toHtml: -> @wrap(@mark() + @content(), 'h' + @type())

class LSetextHeading extends LNode
    toHtml: ->
        if @_mark
            @wrap(@mark(), 'sh' + @type())
        else
            @wrap(@content(), 'sh' + @type())

class LUnorderedList extends LNode
    htmlclass: 'ul'
    toHtml: -> @wrap(@mark() + @content())

class LOrderedList extends LUnorderedList
    htmlclass: 'ol'

class LQuote extends LUnorderedList
    htmlclass: 'quote'

############
# Code Blocks
############

class LCodeblock extends LNode
    htmlclass: 'code'
    toHtml: -> @wrap(@content())

class LGithubCodeblock extends LNode
    htmlclass: 'code'
    toHtml: -> if @_mark then @mark() else @wrap(@content())

############
# Special Block level
############

class LEmpty extends LNode
    toHtml: -> if @content() then @content() else ''

class LParagraph extends LEmpty

############
# Public API
############
window.markdown =

    toJson: (text) -> lighter_markdown_parser.parse(text)
    toHtml: (text) ->
        html = ''
        parsed_json = lighter_markdown_parser.parse(text)
        for block in parsed_json
            html += block.toHtml() + '</br>'
        html
