# frozen_string_literal: true
class Operation
  attr_reader :operation, :arguments

  def initialize(operation, *arguments)
    @operation = operation
    @arguments = arguments
  end

  def to_s
    "<Operation: #{operation}: #{arguments.join(', ')}>"
  end
end

class Parser < Rly::Yacc
  rule 'statement : NAME "=" expression' do |statement, name, _, expression|
    puts "Parser: (statement : NAME = expression) => name: #{name.inspect}, expression: #{expression.inspect}"
    statement.value = Operation.new(:assign, name, expression)
  end

  rule 'statement : expression' do |statement, expression|
    puts "Parser: (statement : expression) => expression: #{expression.inspect}"

    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : NAME' do |expression, name|
    puts "Parser: (expression : NAME) => name: #{name.inspect}"
    if ['quit', 'exit'].include?(name.value)
      puts "Parser: NAME is 'quit' or 'exit'; quitting..."
      exit 0
    end

    expression.value = Operation.new(:lookup, name)
  end

  rule 'expression : NUMBER' do |expression, number|
    puts "Parser: (expression : NUMBER) => #{number.inspect}"
    expression.value = Operation.new(:number, number.value)
  end
end
