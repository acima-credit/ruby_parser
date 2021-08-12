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
  precedence :left, '+', '-'
  precedence :left, '*', '/'
  precedence :left, '%', '^'

  rule 'statement : NAME "=" expression' do |statement, name, equals, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : FUNCTION "(" ")" FUNCTION_ARROW expression'  do |expression, _function, _left_parentesis, _right_parentesis, _equal, body_function|
    expression.value = Operation.new(:function, body_function.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, number.value)
  end

  rule 'expression : NAME' do |expression, name|
    exit(0) if ["exit", "quit"].include?(name.value)
    expression.value = Operation.new(:lookup, name.value)
  end

  

  rule 'expression : expression "+" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:+, number_a.value, number_b.value)
  end

  rule 'expression : expression "-" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:-, number_a.value, number_b.value)
  end

  rule 'expression : expression "*" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:*, number_a.value, number_b.value)
  end

  rule 'expression : expression "/" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:/, number_a.value, number_b.value)
  end

  rule 'expression : expression "%" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:%, number_a.value, number_b.value)
  end

  rule 'expression : expression "^" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:^, number_a.value, number_b.value)
  end


  # NOTES:  we discusses about how the parser reads the expressions from right to left and from bottom-top and clarify a lot of the questions
  # We notice we need to add an operator in the interpreter for the CASE like "when :+ then number(*tree.arguments)" We are missin the then s tatement though"
  # Things to be done:
  # -arithmetic functions
  # -parenthesis
  # -variable assignment

end
