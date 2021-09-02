require "rly"
require "./parser"
require "./interpreter"
require "./test_framework"

class TestInterpreter < TestFramework
  it "evaluates number correctly" do
    parse_tree = Operation.new(:number, 1)
    result = Interpreter.new.evaluate(parse_tree)

    assert(result == 1)
  end

  it "evaluates assign correctly" do
    interpreter = Interpreter.new
    number_expression = Operation.new(:number, 1)
    assign_expression = Operation.new(:assign, "x", number_expression)
    assign_result = interpreter.evaluate(assign_expression)

    lookup_expression = Operation.new(:lookup, "x")
    result = interpreter.evaluate(lookup_expression)

    assert(result == 1.0)
  end

  it "evaluates evaluate correctly" do
    interpreter = Interpreter.new
    number_expression = Operation.new(:number, 1)
    evaluate_expression = Operation.new(:evaluate, number_expression)

    result = Interpreter.new.evaluate(evaluate_expression)
    assert(result == 1)
  end

  run
end
