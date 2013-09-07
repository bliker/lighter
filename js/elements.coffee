namespace = (target, name, block) ->
  [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
  top    = target
  target = target[item] or= {} for item in name.split '.'
  block target, top

namespace 'Markdown', (exports) ->
  class Node
    constructor: (data) ->
      @_mark = data.mark
      @_type = data.type
      @_content = data.content
      # if data.spanble

    wrap: (content, htmlclass) ->
      htmlclass = @htmlclass unless htmlclass
      '<span class="lighter_'+htmlclass+'">'+content+'</span>'

    toString: -> (if @_mark then @_mark else '') + (if @_content then @_content else '')
    mark: -> @wrap(@_mark, 'mark')
    content: -> @_content
    type: -> @_type

  class exports.AtxHeading extends Node
    toHtml: -> @wrap(@mark() + @content(), 'h' + @type())

  class exports.SetextHeading extends Node
    toHtml: ->
      if @_mark
        @wrap(@mark(), 'sh' + @type())
      else
        @wrap(@content(), 'sh' + @type())

  class exports.UnorderedList extends Node
    htmlclass: 'ul'
    toHtml: -> @wrap(@mark() + @content())

  class exports.OrderedList extends exports.UnorderedList
    htmlclass: 'ol'

  class exports.Quote extends exports.UnorderedList
    htmlclass: 'quote'

  class exports.Codeblock extends Node
    htmlclass: 'code'
    toHtml: -> @wrap(@content())

  class exports.GithubCodeblock extends Node
    htmlclass: 'code'
    toHtml: -> if @_mark then @mark() else @wrap(@content())

  class exports.Empty extends Node
    toHtml: -> if @content() then @content() else ''

  class exports.Paragraph extends exports.Empty