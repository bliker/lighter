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
    toHtml: ->
        if @_mark
            return @mark()
        else
            return @wrap(@content())

############
# Special Block level
############

class LEmpty extends LNode
    toHtml: -> @content()

class LParagraph extends LEmpty


