TokenIterator = require "../src/token-iterator"

module.exports =
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

  getScopes: ->
    @tokenIterator.getScopes()

  getScopeStarts: ->
    @tokenIterator.getScopeStarts()

  getScopeEnds: ->
    @tokenIterator.getScopeEnds()

  getTokenStart: ->
    @tokenStart

  getTokenEnd: ->
    @tokenEnd

  next: ->
    @tokenTextIndex += @currentCharLength
    @lineCharIndex  += @currentCharLength

    if @tokenTextIndex >= @tokenText.length
      return false unless @tokenIterator.next()

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
    @currentChar or ""

  getCharIndex: ->
    @lineCharIndex

  getTokenText: ->
    @tokenText

  getCharIndexWithinToken: ->
    @tokenTextIndex

  isHardTab: ->
    @tokenIterator.isHardTab()

  isInsideLeadingWhitespace: ->
    @lineCharIndex < @lineState.firstNonWhitespaceIndex

  isInsideTrailingWhitespace: ->
    @lineCharIndex + @currentCharLength > @lineState.firstTrailingWhitespaceIndex

  isAtEndOfToken: ->
    @tokenTextIndex + @currentCharLength is @tokenText.length

  isAtBeginningOfToken: ->
    @tokenTextIndex is 0

  beginsLeadingWhitespace: ->
    @isInsideLeadingWhitespace() and @isAtBeginningOfToken()

  endsLeadingWhitespace: ->
    tokenLeadingWhitespaceEndIndex =
      Math.min(@tokenEnd, @lineState.firstNonWhitespaceIndex)

    @lineCharIndex + @currentCharLength is tokenLeadingWhitespaceEndIndex

  beginsTrailingWhitespace: ->
    tokenTrailingWhitespaceStartIndex =
      Math.max(0, @lineState.firstTrailingWhitespaceIndex - @tokenStart)

    @tokenTextIndex is tokenTrailingWhitespaceStartIndex

  endsTrailingWhitespace: ->
    @isInsideTrailingWhitespace() and @isAtEndOfToken()
