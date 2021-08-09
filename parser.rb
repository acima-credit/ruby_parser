# frozen_string_literal: true

class Operation
  attr_reader :operation, :arguments

  def initialize(operation, *arguments)
    @operation = operation
    @arguments = arguments
  end

  def to_s
    "(#{operation}: #{arguments.join(', ')})"
  end
end

class Parser < Rly::Yacc
  precedence :left, :PHILLIPS, :FLATHEAD
  precedence :left, :TORX, :RAZOR
  precedence :left, :ANGLE_BRACKET

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  # 5 - 3 
  rule 'expression : expression FLATHEAD expression' do |expression, expression_1, _tool, expresion_2|
    expression.value = Operation.new(:subtract, expression_1.value, expresion_2.value)
  end

  

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, expression.value)
  end

  rule 'expression : NAME' do ||
 end
