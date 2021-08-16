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
    expression.value = Operation.new(:function, nil, body_function.value)
  end

  rule 'expression : FUNCTION "(" parameter_list ")" FUNCTION_ARROW expression'  do |expression, _function, _left_parentesis, parameter_list, _right_parentesis, _equal, body_function|
    expression.value = Operation.new(:function, parameter_list.value, body_function.value)
  end

  rule 'parameter : NAME' do |parameter, name|
    parameter.value = name.value
  end

  rule 'parameter_list : parameter | parameter "," parameter_list ' do |parameter_list, parameter, _comma, list|
    parameter_list.value = Array(parameter.value) + Array(list&.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, number.value)
  end

  rule 'expression : NAME' do |expression, name|
    exit(0) if ["exit", "quit"].include?(name.value)
    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression_list : expression | expression "," expression_list' do |expression_list, expression, _comma, list|
    expression_list.value = Array(expression.value) + Array(list&.value)
  end

  rule 'expression : NAME "(" expression_list ")"' do |expression, name, _lpar, parameter_expression, _rpar|
    expression.value = Operation.new(:evaluate_function, name, parameter_expression.value)
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

end
