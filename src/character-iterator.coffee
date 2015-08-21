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
    @hasNoMoreTokens = false

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

  advanceToNextNonEmptyToken: ->
    return false unless @tokenIterator.next()

    @tokenText = @tokenIterator.getText()
    @tokenStart = @tokenIterator.getScreenStart()
    @tokenEnd = @tokenIterator.getScreenEnd()
    @tokenTextIndex = 0

    if @tokenText.length > 0
      true
    else
      @advanceToNextNonEmptyToken()

  next: ->
    return false if @hasNoMoreTokens

    @tokenTextIndex += @currentCharLength
    @lineCharIndex  += @currentCharLength

    if @tokenTextIndex >= @tokenText.length
      @hasNoMoreTokens = not @advanceToNextNonEmptyToken()
      return false if @hasNoMoreTokens

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

  isHardTab: ->
    @tokenIterator.isHardTab()

  isInsideLeadingWhitespace: ->
    @lineCharIndex < @lineState.firstNonWhitespaceIndex

  isInsideTrailingWhitespace: ->
    @lineCharIndex + @currentCharLength > @lineState.firstTrailingWhitespaceIndex

  isAtEndOfToken: ->
    @lineCharIndex + @currentCharLength is @tokenEnd

  isAtBeginningOfToken: ->
    @lineCharIndex is @tokenStart

  beginsLeadingWhitespace: ->
    @isInsideLeadingWhitespace() and @isAtBeginningOfToken()

  endsLeadingWhitespace: ->
    leadingWhitespaceEndIndex =
      Math.min(@tokenEnd, @lineState.firstNonWhitespaceIndex)

    @lineCharIndex + @currentCharLength is leadingWhitespaceEndIndex

  beginsTrailingWhitespace: ->
    trailingWhitespaceStartIndex =
      Math.max(@tokenStart, @lineState.firstTrailingWhitespaceIndex)

    @lineCharIndex is trailingWhitespaceStartIndex

  endsTrailingWhitespace: ->
    @isInsideTrailingWhitespace() and @isAtEndOfToken()
