class Tag
  constructor: (name, className) ->
    return new Tag(arguments...) unless this instanceof Tag

    @name = name
    @className = className

  getOpeningString: ->
    html = "<#{@name}"
    html += " class='#{@className}'" if @className?
    html += ">"
    html

  getClosingString: ->
    "</#{@name}>"

class HtmlBuilder
  constructor: ->
    @buffer = ""
    @openTags = []
    @tagsToReopen = []

  reset: ->
    @buffer = ""
    @openTags.length = 0
    @tagsToReopen.length = 0

  openTag: (tag) ->
    @openTags.push(tag)
    @put(tag.getOpeningString())
    tag

  closeTag: (tag) ->
    while openTag = @openTags.pop()
      @put(openTag.getClosingString())
      break if openTag is tag
      @tagsToReopen.push(openTag)

  reopenTags: ->
    while tag = @tagsToReopen.pop()
      @openTag(tag)

  put: (text) ->
    @buffer += text

  toString: ->
    @buffer

module.exports = {HtmlBuilder, Tag}
