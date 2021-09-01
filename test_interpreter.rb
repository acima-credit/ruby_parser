require "rly"
require "./parser"
require "./interpreter"
require "./test_framework"

class TestInterpreter < TestFramework
  it "should evaluate numbers correctly" do
    parse_tree = Operation.new(
      :number,
      1
    )
    result = Interpreter.new(nil).evaluate(parse_tree)

    assert(result == 1)
  end

  run
end