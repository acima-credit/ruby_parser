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

  def self.log(msg)
    $stdout.puts "Parser: #{msg}".black.on_light_blue
    $stdout.flush
  end

  def log(msg)
    self.class.log(msg)
  end

  precedence :left, :PHILLIPS, :FLATHEAD
  precedence :left, :TORX, :RAZOR
  precedence :left, :SQUARE

  # Exit by sending to interpreter, ignoring _close param
  rule 'statement : CLOSE_TOOLBOX' do |statement, _close|
    log "statement : CLOSE_TOOLBOX --> #{_close.value}"
    statement.value = Operation.new(:exit)
  end

  rule 'statement : expression' do |statement, expression|
    log "statement : expression --> #{expression.value}"
    statement.value = Operation.new(:evaluate, expression.value)
  end

  # Assignment x = y   Intentionally ignoring _tool parameter
  rule 'expression : NAME KERF expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : NAME KERF expression --> (:assign, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:assign, expression_1.value, expresion_2.value)
  end

  # Subtraction x - y   Intentionally ignoring _tool parameter
  rule 'expression : expression FLATHEAD expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression FLATHEAD expression --> (:subtract, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:subtract, expression_1.value, expresion_2.value)
  end

  # Addition x + y  Intentionally ignoring _tool parameter
  rule 'expression : expression PHILLIPS expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression PHILLIPS expression --> (:add #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:add, expression_1.value, expresion_2.value)
  end

  # Multiplication x * y Intentionally ignoring _tool parameter
  rule 'expression : expression TORX expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression TORX expression --> (:multiply, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:multiply, expression_1.value, expresion_2.value)
  end

  # Division x / y Intentionally ignoring _tool parameter
  rule 'expression : expression RAZOR expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression RAZOR expression --> (:divide #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:divide, expression_1.value, expresion_2.value)
  end

  # Exponentiation x ^ y Intentionally ignoring _tool parameter
  rule 'expression : expression SQUARE expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression SQUARE expression --> (:raise, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:raise, expression_1.value, expresion_2.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    log "expression : NUMBER --> #{number.value}"
    expression.value = Operation.new(:number, number.value)
  end

  rule 'expression : NAME' do |expression, name|
    log "expression : NAME --> #{name.inspect}"
    expression.value = Operation.new(:name, name.value)
  end
end
