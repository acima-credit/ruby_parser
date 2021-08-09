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

  rule 'expression : "+" expression' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : "-"' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : "*"' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : "x"' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end

  rule 'expression : "/"' do |statement, expression|
    statement.value = Operation.new(:number, expression.value)
  end
end
