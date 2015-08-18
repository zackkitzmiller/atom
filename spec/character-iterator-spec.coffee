TokenIterator = require "../src/token-iterator"

class CharacterIterator
  constructor: (lineState) ->
    @tokenIterator = new TokenIterator
    @reset(lineState) if lineState?

  reset: (@lineState) ->
    @tokenIterator.reset(lineState)
    @lineCharIndex = 0
    @currentCharLength = 0
    @tokenTextIndex = 0
    @tokenText = ""

  next: ->
    @isNewToken = false
    @tokenTextIndex += @currentCharLength
    @lineCharIndex  += @currentCharLength

    if @tokenTextIndex >= @tokenText.length
      return false unless @tokenIterator.next()

      @isNewToken = true
      @tokenText = @tokenIterator.getText()
      @tokenStart = @tokenIterator.getScreenStart()
      @tokenEnd = @tokenIterator.getScreenEnd()
      @tokenTextIndex = 0

    if @tokenIterator.isPairedCharacter()
      @currentChar = @tokenText
      @currentCharLength = 2
    else
      @currentChar = @tokenText[@tokenTextIndex]
      @currentCharLength = 1

    true

  getChar: ->
    @currentChar

  getCharIndex: ->
    @lineCharIndex

  getTokenText: ->
    @tokenText

  getCharIndexWithinToken: ->
    @tokenTextIndex

  beginsNewToken: ->
    @isNewToken

  beginsLeadingWhitespace: ->
    @lineCharIndex < @lineState.firstNonWhitespaceIndex and @tokenTextIndex is 0

  endsLeadingWhitespace: ->
    @lineCharIndex < @lineState.firstNonWhitespaceIndex and
    @tokenTextIndex + @currentCharLength is @tokenText.length

  beginsTrailingWhitespace: ->
    @lineCharIndex is @lineState.firstTrailingWhitespaceIndex

  endsTrailingWhitespace: ->
    @lineCharIndex > @lineState.firstTrailingWhitespaceIndex and
    @tokenTextIndex + @currentCharLength is @tokenText.length

fdescribe "CharacterIterator", ->
  [editor, iterator] = []

  beforeEach ->
    waitsForPromise ->
      atom.project.open('sample.js').then (o) -> editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    runs ->
      iterator = new CharacterIterator

  it "recognizes new tokens while iterating over characters", ->
    iterator.reset(editor.tokenizedLineForScreenRow(3))

    expect(iterator.next()).toBe(true)
    expect(iterator.beginsNewToken()).toBe(true)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsNewToken()).toBe(false)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsNewToken()).toBe(true)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsNewToken()).toBe(false)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsNewToken()).toBe(true)

  it "recognizes leading whitespaces", ->
    iterator.reset(editor.tokenizedLineForScreenRow(3))

    # First leading-whitespace
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(true)
    expect(iterator.endsLeadingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(false)
    expect(iterator.endsLeadingWhitespace()).toBe(true)
    expect(iterator.getChar()).toBe(" ")

    # Second leading-whitespace
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(true)
    expect(iterator.endsLeadingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(false)
    expect(iterator.endsLeadingWhitespace()).toBe(true)
    expect(iterator.getChar()).toBe(" ")

    while iterator.next()
      expect(iterator.beginsLeadingWhitespace()).toBe(false)
      expect(iterator.endsLeadingWhitespace()).toBe(false)

    expect(iterator.next()).toBe(false)

  it "recognizes trailing whitespaces", ->
    editor.setText("hey    ")
    iterator.reset(editor.tokenizedLineForScreenRow(0))

    # Leading Text
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(false)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(false)
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(false)

    # Trailing Whitespace
    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(true)
    expect(iterator.endsLeadingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")

    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")

    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")

    expect(iterator.next()).toBe(true)
    expect(iterator.beginsTrailingWhitespace()).toBe(false)
    expect(iterator.endsTrailingWhitespace()).toBe(true)
    expect(iterator.getChar()).toBe(" ")

    expect(iterator.next()).toBe(false)
