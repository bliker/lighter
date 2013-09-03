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

        return html_blocks

    # Create Json form markdown text
    createJson: ->
        current_block = @blocks[@index];
        console.log('Parsing block:', current_block);
        block_parsed = false
        for k, parser of @parsers
            parsed = parser.apply(this)

            # Save parsed block to array and leave the parsing loop
            if parsed
                @blocks[@index] = parsed
                block_parsed = true
                break

        ## Not parsed by regular stuff, must be paragrpah
        if not block_parsed
            @blocks[@index] = new LParagraph({content: current_block})

        # Index
        @index++
        if @blocks.length > @index
            # recrusive call for parsing
            @createJson()
        else
            # All blocks are parsed
            return @blocks

    createHtml: ->
        newtext = ''
        for block in @blocks
            newtext += block.toHtml() + '</br>'

        return newtext

    parsers:

        atxheading: ->
            current = @blocks[@index]
            return false if current[0] isnt '#'

            i = 1
            i++ while current[i] is '#' and i < 6

            # mark + content
            new LAtxHeading({
                mark: current.substr(0, i),
                content: current.substr(i)
                type: i
            })

        setextheading: ->
            current = @blocks[@index]
            next = @blocks[@index+1]

            char = ['=', '-'].indexOf(next[0]);
            # Ignore this right away
            return false if not next or char < 0

            i = 1
            # Check if first character is there until the end of line
            i++ while next[i] is next[0]
            return false if i isnt next.trim().length

            @blocks[@index] = new LSetextHeading({
                content: current,
                type: char + 1
            })

            # Blockskipping
            @index++
            new LSetextHeading({
                mark: next
                type: char + 1
            })

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

            new LUnorderedList({
                mark: current.substr(0, i)
                content: current.substr(i)
            });

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

            new LOrderedList({
                mark: current.substr(0, i+1)
                content: current.substr(i+1)
            })

        quote: ->
            current = @blocks[@index]

            return false if (current[0] isnt '>') or (current[1] isnt " ")
            # Nested quotes not supported yet!

            new LQuote({
                mark: current[0]
                content: current.substr(1)
            })

        empty: ->
            current = @blocks[@index]

            return false if current.trim().length

            new LEmpty({content: current})

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

            new LCodeblock({content: current})

        codeblockg: ->
            current = @blocks[@index]

            return false if not open_backticks = @is_codeblock_seq(current)
            @blocks[@index] = new LGithubCodeblock({mark: current})

            # Non sandard block skipping in here
            @index++
            while @blocks[@index] and not close_backticks = @is_codeblock_seq(@blocks[@index])
                @blocks[@index] =  new LGithubCodeblock({content: @blocks[@index]})
                @index++

            # Last block has to be returned instead of assgined
            new LGithubCodeblock({mark: @blocks[@index]});



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

###### Element classes

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

###### Code

class LCodeblock extends LNode
    htmlclass: 'code'
    toHtml: -> @wrap(@content())

class LGithubCodeblock extends LNode
    htmlclass: 'code'
    toHtml: ->
        if @_mark
            return @mark()
        else
            return @wrap(@content())

###### Empty

class LEmpty extends LNode
    toHtml: -> @content()

class LParagraph extends LEmpty


