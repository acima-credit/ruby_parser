require "rly"
require "./test_framework"
require "./parser"
require "./lexer"

class TestParser < TestFramework
  class MockLexer
    def initialize(token_array)
      @token_array = token_array
      @current_token = 0
    end

    def next
      index = @current_token
      @current_token += 1
      @token_array[index]
    end

    def self.terminals
      Lexer.terminals
    end
  end

  class MockToken
    attr_reader :type, :value

    def initialize(type, value)
      @type = type
      @value = value
    end
  end

  it "should parse a number expression as a number operation" do
    lexer = MockLexer.new([MockToken.new(:NUMBER, 1)])
    parser = Parser.new(lexer)
    parsed_tree = parser.parse

    puts parsed_tree
    assert(parsed_tree.operation == :evaluate)

    evaluate_value = parsed_tree.argument
    assert(evaluate_value.operation == :number)
    assert(evaluate_value.argument == 1)
  end

  run
end