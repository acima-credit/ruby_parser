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
  precedence :left, :PLUS, :HYPHEN
  precedence :left, :STAR, '/', '%'
  precedence :left, '^'
  precedence :right, :UMINUS

  def self.log(msg)
    $stdout.puts "Parser: #{msg}".black.on_cyan
    $stdout.flush
  end

  def log(msg)
    self.class.log msg
  end

  rule 'statement : NAME EQUAL expression' do |statement, name, _, expression|
    log "statement : NAME EQUAL expression -> (:assign, #{name.value}, #{expression.value})"
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    log "statement : expression -> (:evaluate, #{expression.value})"
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : HYPHEN expression %prec UMINUS' do |expression, _neg, exp|
    log "expression : HYPHEN expression %prec UMINUS -> (:negate, #{exp.value})"
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : LPAREN expression RPAREN' do |expression, _lparen, exp, _rparen|
    log "expression : LPAREN expression RPAREN -> expression=#{exp.value}"
    expression.value = exp.value
  end

  rule 'expression : expression PLUS expression' do |expression, a, _operation, b|
    log "expression : expression PLUS expression -> (:+, #{a.value}, #{b.value})"
    expression.value = Operation.new(:+, a.value, b.value)
  end

  rule 'expression : expression HYPHEN expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:-, a.value, b.value)
  end

  rule 'expression : expression STAR expression' do |expression, a, _operation, b|
    log "expression : expression STAR expression -> (:+, #{a.value}, #{b.value})"
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
    log "expression : NAME -> (:lookup, #{name.value})"
    exit(0) if %w[quit exit].include?(name.value)

    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    log "expression : NUMBER -> (:number, #{number.value.to_i})"
    expression.value = Operation.new(:number, number.value.to_i)
  end

  rule 'statement : expression expression' do |statement, expression_1, expression_2|
    log "statement : expression expression -> ??? expression_1 = #{expression_1.value}, expression_2 = #{expression_2.value}"
    fail "You can't do that."
  end
end
