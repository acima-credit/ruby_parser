# frozen_string_literal: true
require 'forwardable'
class Operation
  extend Forwardable

  attr_reader :operation, :arguments, :argument

  def_delegator :@argument, :map

  def initialize(operation, *arguments)
    @operation = operation
    @arguments = arguments
    @argument  = arguments.first
  end

  def list?
    operation == :list
  end

  def function?
    operation == :function
  end

  def to_s
    "(#{operation}: #{arguments.join(', ')})"
  end
end

class Parser < Rly::Yacc
  precedence :left, '+', '-'
  precedence :left, '*', '/', '%'
  precedence :left, '^'
  precedence :right, :UMINUS

  rule 'statement : NAME "=" expression'\
  do |statement, name, _, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression'\
  do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : "-" expression %prec UMINUS'\
  do |expression, _neg, exp|
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : "(" expression ")"'\
  do |expression, _lparen, exp, _rparen|
    expression.value = exp.value
  end

  rule 'expression : expression "+" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:+, a.value, b.value)
  end

  rule 'expression : expression "-" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:-, a.value, b.value)
  end

  rule 'expression : expression "*" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:*, a.value, b.value)
  end

  rule 'expression : expression "/" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:/, a.value, b.value)
  end

  rule 'expression : expression "%" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:%, a.value, b.value)
  end

  rule 'expression : expression "^" expression'\
  do |expression, a, _operation, b|
    expression.value = Operation.new(:^, a.value, b.value)
  end

  rule 'expression : NAME'\
  do |expression, name|
    exit(0) if %w[quit exit].include?(name.value)

    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : NUMBER'\
  do |expression, number|
    expression.value = Operation.new(:number, number.value.to_i)
  end

  rule 'parameter : NAME | FNAME'\
  do |parameter, name|
    parameter.value = name.value
  end

  rule 'parameter_list : parameter | parameter "," parameter_list'\
  do |parameter_list, param, _comma, list|
    parameter_list.value = Array(param.value) + Array(list&.value)
  end

  rule 'expression_list : expression | expression "," expression_list'\
  do |expression_list, exp, _comma, list|
    expression_list.value = Array(exp.value) + Array(list&.value)
  end

  rule 'expression : LAMBDA "\" parameter_list "\" expression | LAMBDA "." "." "." expression'\
  do |expression, _lambda, _, params, _, exp|
    list = params.value == '.' ? [] : params.value
    expression.value = Operation.new(:function, list, exp.value)
  end

  rule 'expression : "{" expression_list "}"'\
  do |expression, _lcurly, expression_list, _rcurly|
    expression.value = Operation.new(:list, expression_list.value)
  end

  rule 'expression : "[" expression_list "]" COMPOSE NAME'\
  do |expression, _lbracket, list, _rbracket, _compose, name|
    expression.value = Operation.new(:lookup, name.value, list.value)
  end

  rule 'compose_list : COMPOSE NAME | COMPOSE math_compose | COMPOSE NAME compose_list | COMPOSE math_compose compose_list'\
  do |compose_list, _compose, name, list|
    compose_list.value = Array(name.value) + Array(list&.value)
  end

  rule 'expression : expression compose_list'\
  do |expression, exp, list|
    expression.value = Operation.new(:compose, exp.value, list.value)
  end

  rule 'math_compose :
      "|" "+" NUMBER "|"
    | "|" "-" NUMBER "|"
    | "|" "*" NUMBER "|"
    | "|" "/" NUMBER "|"
    | "|" "%" NUMBER "|"
    | "|" "^" NUMBER "|"'\
  do |compose, _lpipe, operator, number, _rpipe|
    expression = Operation.new(operator.value.to_sym, Operation.new(:lookup, 'abc'), Operation.new(:number, number.value.to_i))
    compose.value = Operation.new(:function, 'abc', expression)
  end
end

# <Operation:0x00007f829914d660
#  @argument=#<Operation:0x00007f829914ea10 @argument="abc", @arguments=["abc"], @operation=:lookup>,
#  @arguments=[#<Operation:0x00007f829914ea10 @argument="abc", @arguments=["abc"], @operation=:lookup>, #<Operation:0x00007f829914dc00 @argument=2, @arguments=[2], @operation=:number>],
#  @operation=:+>
# <Operation:0x00007fd5f10d3120
# @argument=#<Operation:0x00007fd5f10d3238 @argument=["abc"], @arguments=[["abc"]], @operation=:lookup>,
# @arguments=[#<Operation:0x00007fd5f10d3238 @argument=["abc"], @arguments=[["abc"]], @operation=:lookup>, #<Operation:0x00007fd5f10d31c0 @argument=2, @arguments=[2], @operation=:number>],
# @operation=:+>