CharacterIterator = require "../src/character-iterator"

fdescribe "CharacterIterator", ->
  [editor, iterator] = []

  beforeEach ->
    waitsForPromise ->
      atom.project.open('sample.js').then (o) -> editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-javascript')

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

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

  it "recognizes leading whitespaces (hard tabs)", ->
    editor.setText("\t\thello")
    iterator.reset(editor.tokenizedLineForScreenRow(0))

    # First leading-whitespace
    expect(iterator.next()).toBe(true)
    expect(iterator.isHardTab()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(true)
    expect(iterator.endsLeadingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")
    expect(iterator.next()).toBe(true)
    expect(iterator.isHardTab()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(false)
    expect(iterator.endsLeadingWhitespace()).toBe(true)
    expect(iterator.getChar()).toBe(" ")

    # Second leading-whitespace
    expect(iterator.next()).toBe(true)
    expect(iterator.isHardTab()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(true)
    expect(iterator.endsLeadingWhitespace()).toBe(false)
    expect(iterator.getChar()).toBe(" ")
    expect(iterator.next()).toBe(true)
    expect(iterator.isHardTab()).toBe(true)
    expect(iterator.beginsLeadingWhitespace()).toBe(false)
    expect(iterator.endsLeadingWhitespace()).toBe(true)
    expect(iterator.getChar()).toBe(" ")

    while iterator.next()
      expect(iterator.beginsLeadingWhitespace()).toBe(false)
      expect(iterator.endsLeadingWhitespace()).toBe(false)
      expect(iterator.isHardTab()).toBe(false)

    expect(iterator.next()).toBe(false)

  it "recognizes leading whitespaces (soft tabs)", ->
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
