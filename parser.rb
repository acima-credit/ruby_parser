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

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : NUMBER' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : expression "+" expression' do |expression, value_one, _operation, value_two|
    expression.value = Operation.new(:+, value_one.value, value_two.value)
  end

  # rule 'expression : "-" expression' do |statement, expression|
  #   expression.value = Operation.new(:-, expression.value)
  # end

  # rule 'expression : "*" expression' do |statement, expression|
  #   expression.value = Operation.new(:number, expression.value)
  # end

  # rule 'expression : "x" expression' do |statement, expression|
  #   expression.value = Operation.new(:number, expression.value)
  # end

  # rule 'expression : "/" expression' do |statement, expression|
  #   expression.value = Operation.new(:number, expression.value)
  # end
end
