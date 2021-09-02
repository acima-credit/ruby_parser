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
    $stdout.puts "Parser: #{msg}".white.on_blue
    $stdout.flush
  end

  def log(msg)
    self.class.log(msg)
  end

  precedence :left, :PHILLIPS, :FLATHEAD
  precedence :left, :TORX, :RAZOR, :PULLEY
  precedence :left, :SQUARE
  precedence :right, :UMINUS

  # Exit by sending to interpreter, ignoring _close param
  rule 'statement : CLOSE_TOOLBOX' do |statement, _close|
    log "statement : CLOSE_TOOLBOX --> #{_close.value}"
    statement.value = Operation.new(:close)
  end

  rule 'statement : expression' do |statement, expression|
    log "statement : expression --> #{expression.value}"
    statement.value = Operation.new(:evaluate, expression.value)
  end

  # Assignment x = y  ignoring _tool parameters
  rule 'expression : NAME KERF expression' do |expression, name, _tool1, expression_1|
    log "expression : NAME KERF expression --> (:assign, #{name.value}, #{expression_1.value})"
    expression.value = Operation.new(:assign, name.value, expression_1.value)
  end

# # copycat:
# rule 'arg_list : NAME
#                 | NAME "," arg_list' do |arg_list, name, _, agr_list|
#   puts "Parser#arg_list: #{name.inspect} + #{agr_list.inspect}" if verbose
#   arg_list.value = Array(name) + Array(agr_list)
# end

  # params (must be defined before the actual function definition)
  rule 'params : NAME
               | NAME RIVET params' do |params, name, _tool, params_2|
    log "params : NAME | NAME RIVET params --> (:params, #{name.inspect}, #{params_2.inspect})"
    params.value = Array(name) + Array(params_2)
  end

  # Function definition x ~ 4 + 6  ignoring _tool parameters
  # Function definition with parameters: x with b, c ~ b + c
  rule 'expression : NAME SCREW expression
                   | NAME WITH params SCREW expression' do |expression, name, _tool_1, params, _tool_2, expression_1|
    log "expression : NAME SCREW expression --> (:declare, #{name.inspect}, #{expression_1.inspect})"
    expression.value = Operation.new(:declare, name.value, expression_1.value)
  end



  # # Function call example: ring multiply with 3 and 5 (function lookup) ignoring _tool parameters
  # rule 'expression : RING NAME
  #                  | RING NAME WITH values' do |expression, _tool, name|
  #   log "expression : RING NAME --> (:ring, #{name.value})"
  #   expression.value = Operation.new(:ring, name.value)
  # end

  # # arguments can be like: 3
  # #                    or: 3 and 4
  # #                    or: 3 and 4 and 19
  # rule 'values : expression
  #              | expression AND values'

  # Parenthesis - ignoring _tool parameters
  rule 'expression : LEFT_HOOK expression RIGHT_HOOK' do |expression, _tool1, expression_1, _tool2|
    log "expression : LEFT_HOOK expression RIGHT_HOOK --> (:evaluate, #{expression_1.value})"
    expression.value = Operation.new(:evaluate, expression_1.value)
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
    log "expression : expression SQUARE expression --> (:power, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:power, expression_1.value, expresion_2.value)
  end

  # Using a modulus x % y Intentionally ignoring _tool parameter
  rule 'expression : expression PULLEY expression' do |expression, expression_1, _tool, expresion_2|
    log "expression : expression PULLEY expression --> (:modulo, #{expression_1.value}, #{expresion_2.value})"
    expression.value = Operation.new(:modulo, expression_1.value, expresion_2.value)
  end

  # Negate -x Intentionally ignoring _tool parameter
  rule 'expression : FLATHEAD expression %prec UMINUS' do |expression, _tool, expression_1|
    log "expression : FLATHEAD expression %prec UMINUS --> (:negate, #{expression_1.value})"
    expression.value = Operation.new(:negate, expression_1.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    log "expression : NUMBER --> #{number.value}"
    expression.value = Operation.new(:number, number.value)
  end

  rule 'expression : NAME' do |expression, name|
    log "expression : NAME --> #{name.inspect}"
    expression.value = Operation.new(:lookup, name.value)
  end
end
