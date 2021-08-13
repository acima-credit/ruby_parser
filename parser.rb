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
  precedence :left, '*', '/', '%'
  precedence :left, '^'

  rule 'statement : QUIT' do |statement, _quit|
    statement.value = Operation.new(:quit)
  end

  rule 'statement : NAME "=" expression' do |statement, name, _, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : NAME' do |expression, name|
    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : NUMBER' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : expression "+" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:+, value1.value, value2.value)
  end

  rule 'expression : expression "-" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:-, value1.value, value2.value)
  end

  rule 'expression : expression "/" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:/, value1.value, value2.value)
  end

  rule 'expression : expression "*" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:*, value1.value, value2.value)
  end

  rule 'expression : expression "%" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:%, value1.value, value2.value)
  end

  rule 'expression : expression "^" expression' do |expression, value1, operation, value2|
    expression.value = Operation.new(:**, value1.value, value2.value)
  end

  rule 'expression : "(" expression ")" ' do |expression1, _, expression2, _|
    expression1.value = Operation.new(:evaluate, expression2.value)
  end
end
