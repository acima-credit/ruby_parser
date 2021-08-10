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
  precedence :right, :NEGATIVE

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : NUMBER' do |statement, expression|
    statement.value = Operation.new(:number, expression.value.to_i)
  end

  rule 'statement : NAME "=" expression' do |statement, name, _equal, expression|
    statement.value = Operation.new(:assignment, name.value, expression.value)
  end

  rule 'expression : NAME' do |expression, name|
    exit(0) if %w[quit exit].include?(name.value)

    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : "-" expression %prec NEGATIVE'\
  do |expression, _neg, exp|
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : expression "+" expression' do |expression, a, _add, b|
    expression.value = Operation.new(:+, a.value, b.value)
  end

  rule 'expression : expression "-" expression' do |expression, a, _subtract, b|
    expression.value = Operation.new(:-, a.value, b.value)
  end

  rule 'expression : expression "*" expression' do |expression, a, _multiply, b|
    expression.value = Operation.new(:*, a.value, b.value)
  end

  rule 'expression : expression "%" expression' do |expression, a, _modulo, b|
    expression.value = Operation.new(:%, a.value, b.value)
  end

  rule 'expression : expression "/" expression' do |expression, a, _divide, b|
    expression.value = Operation.new(:/, a.value, b.value)
  end

  rule 'expression : expression "^" expression' do |expression, a, _exponent, b|
    expression.value = Operation.new(:^, a.value, b.value)
  end
end
