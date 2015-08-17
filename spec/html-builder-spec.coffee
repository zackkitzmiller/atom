HtmlBuilder = require '../src/html-builder'

describe "HtmlBuilder", ->
  htmlBuilder = null

  beforeEach ->
    htmlBuilder = new HtmlBuilder

  it "works with flat structures", ->
    tag1 = htmlBuilder.openTag("span")
    htmlBuilder.put("h")
    htmlBuilder.put("i")
    htmlBuilder.closeTag(tag1)

    expect(htmlBuilder.toString()).toEqual("<span>hi</span>")

  it "works with nested structures", ->
    tag1 = htmlBuilder.openTag("div")
    tag2 = htmlBuilder.openTag("span")
    htmlBuilder.put("h")
    htmlBuilder.put("i")
    htmlBuilder.closeTag(tag2)
    htmlBuilder.closeTag(tag1)

    expect(htmlBuilder.toString()).toEqual("<div><span>hi</span></div>")

  it "automatically reopens tags that cross many DOM elements", ->
    tag1 = htmlBuilder.openTag("div")
    tag2 = htmlBuilder.openTag("span")
    htmlBuilder.put("h")
    htmlBuilder.put("e")
    htmlBuilder.closeTag(tag1)
    htmlBuilder.put("y")
    htmlBuilder.closeTag(tag2)

    expect(htmlBuilder.toString()).toEqual("<div><span>he</span></div><span>y</span>")

  it "raises an error when some tags are left open", ->
    htmlBuilder.openTag("div")
    htmlBuilder.openTag("div")
    htmlBuilder.openTag("div")

    expect(-> htmlBuilder.toString()).toThrow()

  # Imperative API to actually work with strings, used by a
  # Declarative API to express what's in the current line

  # Imperative API
  # ==============
  #
  # scopeTag = htmlBuilder.openTag("span", classList: ["scope-a"])
  # htmlBuilder.put("h")
  # htmlBuilder.put("e")
  # selectionTag = htmlBuilder.openTag("span", classList: ["selection"])
  # htmlBuilder.closeTag(scopeTag)
  # htmlBuilder.put("l")
  # htmlBuilder.put("l")
  # htmlBuilder.put("o")
  # htmlBuilder.closeTag(selectionTag)
  # htmlBuilder.toString()

  # Declarative API
  # ===============
  #
  # lineBuilder.reset()
  # lineBuilder.putSelection(screenRange, selection)
  # lineBuilder.putCursor(screenRange, cursor)
  # lineBuilder.putOverlay(screenRange, overlay)
  # lineBuilder.buildLine(tokenizedLine) =>
    # <span class="scope-a">He<span class="region">llo</span></span>
    # <span class="scope-b"><span class="region">Wor</span>ld</span>
