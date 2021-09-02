require "./test_framework"
require "./lexer"

class TestLexer < TestFramework
  it "should load" do
    lexer = Lexer.new
    assert(lexer)
  end

  it "should parse numbers" do
    text = "123 456. 567.89"

    lexer = Lexer.new(text)

    # 123
    token = lexer.next
    assert(token.type == :NUMBER)
    assert(token.value == "123")

    # 456.
    token = lexer.next
    assert(token.type == :NUMBER)
    assert(token.value == "456.")

    # 567.89
    token = lexer.next
    assert(token.type == :NUMBER)
    assert(token.value == "567.89")
  end

  run
end
