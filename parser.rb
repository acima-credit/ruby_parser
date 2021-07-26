# frozen_string_literal: true
class Operation
  attr_reader :operation, :arguments

  def initialize(operation, *arguments)
    @operation = operation
    @arguments = arguments
  end

  def to_s
    "#{operation} : #{arguments.join(', ')}"
  end
end

class Parser < Rly::Yacc
  rule 'statement : NAME "=" expression' do |statement, name, _, expression|
    puts expression
    statement.value = Operation.new(:assign, name, expression)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression)
  end

  rule 'expression : NAME' do |expression, name|
    exit if ['quit', 'exit'].include?(name.value)

    expression.value = Operation.new(:lookup, name)
  end

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, number)
  end
end
