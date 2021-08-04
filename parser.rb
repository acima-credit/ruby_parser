# frozen_string_literal: true
require 'colorize'

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
  precedence :left, :PLUS, '-'
  precedence :left, :STAR, '/', '%'
  precedence :left, '^'
  precedence :right, :UMINUS

  rule 'statement : NAME EQUAL expression' do |statement, name, _, expression|
    puts "Parser: statement : NAME EQUAL expression -> (:assign, #{name.value}, #{expression.value})".black.on_blue
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    puts "Parser: statement : expression -> (:evaluate, #{expression.value})".black.on_blue
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : "-" expression %prec UMINUS' do |expression, _neg, exp|
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : LPAREN expression RPAREN' do |expression, _lparen, exp, _rparen|
    puts "Parser: expression : LPAREN expression RPAREN -> expression=#{exp.value}".black.on_blue
    expression.value = exp.value
  end

  rule 'expression : expression PLUS expression' do |expression, a, _operation, b|
    puts "Parser: expression : expression PLUS expression -> (:+, #{a.value}, #{b.value})".black.on_blue
    expression.value = Operation.new(:+, a.value, b.value)
  end

  rule 'expression : expression "-" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:-, a.value, b.value)
  end

  rule 'expression : expression STAR expression' do |expression, a, _operation, b|
    puts "Parser: expression : expression STAR expression -> (:+, #{a.value}, #{b.value})".black.on_blue
    expression.value = Operation.new(:*, a.value, b.value)
  end

  rule 'expression : expression "/" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:/, a.value, b.value)
  end

  rule 'expression : expression "%" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:%, a.value, b.value)
  end

  rule 'expression : expression "^" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:^, a.value, b.value)
  end

  rule 'expression : NAME' do |expression, name|
    puts "Parser: expression : NAME -> (:lookup, #{name.value})".black.on_blue
    exit(0) if %w[quit exit].include?(name.value)

    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    puts "Parser: expression : NUMBER -> (:number, #{number.value.to_i})".black.on_blue
    expression.value = Operation.new(:number, number.value.to_i)
  end
end
