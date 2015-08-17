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
    @tagsToReopen = []

  reset: ->
    @buffer = ""
    @openTags.length = 0
    @tagsToReopen.length = 0

  openTag: (tag) ->
    tag = Tag.fromObject(tag)
    @openTags.push(tag)
    @put("<#{tag.name}>")
    tag

  closeTag: (tag) ->
    while openTag = @openTags.pop()
      @put("</#{openTag.name}>", false)
      break if openTag is tag
      @tagsToReopen.push(openTag)

  put: (char, reopenTags = true) ->
    if reopenTags
      @openTag(tagToReopen) while tagToReopen = @tagsToReopen.pop()

    @buffer += char

  toString: ->
    throw new Error("Some tags were left open!") if @openTags.length isnt 0

    @buffer
