class Tag
  @fromObject: (obj) ->
    if typeof obj is "string"
      new Tag(obj)
    else
      obj

  constructor: (@name) ->

module.exports =
class HtmlBuilder
  constructor: ->
    @buffer = ""
    @openTags = []

  openTag: (tag) ->
    tag = Tag.fromObject(tag)
    @openTags.push(tag)
    @buffer += "<#{tag.name}>"
    tag

  closeTag: (tag) ->
    tagsToReopen = []
    while openTag = @openTags.pop()
      @buffer += "</#{openTag.name}>"
      break if openTag is tag

      tagsToReopen.push(openTag)

    while tagToReopen = tagsToReopen.pop()
      @openTag(tagToReopen)

  putChar: (char) ->
    @buffer += char

  toString: ->
    throw new Error("Some tags were left open!") if @openTags.length isnt 0

    @buffer
