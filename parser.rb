# frozen_string_literal: true

require 'forwardable'
require 'colorize'

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

  def branch?
    operation == :branch
  end

  def to_s
    "(#{operation.to_s.yellow}: #{arguments.join(', ')})"
  end
end

class Parser < Rly::Yacc
  precedence :left, '~'
  precedence :left, :GTE, :LTE, :GT, :LT, :EQ, :NEQ
  precedence :left, '+', '-'
  precedence :left, '*', '/', '%'
  precedence :left, '^'
  precedence :right, :NEGATIVE

  rule 'statement : EXIT | QUIT'\
  do |statement, _close|
    statement.value = Operation.new(:close)
  end

  rule 'statement : HISTORY'\
  do |statement, _history|
    statement.value = Operation.new(:history)
  end

  rule 'statement : CLEAR'\
  do |statement, _clear|
    statement.value = Operation.new(:clear)
  end

  rule 'statement : SAVE'\
  do |statement, _save|
    statement.value = Operation.new(:save)
  end

  rule 'statement : LOAD'\
  do |statement, _load|
    statement.value = Operation.new(:load)
  end

  rule 'statement : NAME ":" expression'\
  do |statement, name, _assign, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression'\
  do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : "-" expression %prec NEGATIVE'\
  do |expression, _neg, exp|
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : "(" expression ")"'\
  do |expression, _lparen, exp, _rparen|
    expression.value = exp.value
  end

  rule 'function_body : expression | expression "." function_body | statement "." function_body'\
  do |function_body, exp, _period, body|
    function_body.value = Array(exp.value) + Array(body&.value)
  end

  rule 'expression : LAMBDA "\" parameter_list "\" function_body | LAMBDA "." "." "." function_body'\
  do |expression, _lambda, _, params, _, function_body|
    list = params.value == '.' ? [] : params.value
    expression.value = Operation.new(:function, list, function_body.value)
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

  rule 'expression : expression LTE expression'\
  do |expression, exp1, _lte, exp2|
    expression.value = Operation.new(:lte, exp1.value, exp2.value)
  end

  rule 'expression : "~" expression'\
  do |expression, _not, exp|
    expression.value = Operation.new(:~, exp.value)
  end

  rule 'expression : expression GTE expression'\
  do |expression, exp1, _gte, exp2|
    expression.value = Operation.new(:gte, exp1.value, exp2.value)
  end

  rule 'expression : expression NEQ expression'\
  do |expression, exp1, _neq, exp2|
    expression.value = Operation.new(:neq, exp1.value, exp2.value)
  end

  rule 'expression : expression LT expression'\
  do |expression, exp1, _lt, exp2|
    expression.value = Operation.new(:lt, exp1.value, exp2.value)
  end

  rule 'expression : expression GT expression'\
  do |expression, exp1, _gt, exp2|
    expression.value = Operation.new(:gt, exp1.value, exp2.value)
  end

  rule 'expression : expression EQ expression'\
  do |expression, exp1, _eq, exp2|
    expression.value = Operation.new(:eq, exp1.value, exp2.value)
  end

  rule 'expression : NAME'\
  do |expression, name|
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

  rule 'expression : "{" expression_list "}"'\
  do |expression, _lcurly, expression_list, _rcurly|
    expression.value = Operation.new(:list, expression_list.value)
  end

  # ∘ func ⌥ func | func ∘
  rule 'branch_compose : NAME BRANCH NAME "|" NAME'\
  do |compose, check, _branch, truthy, _pipe, falsey|
    compose.value = Operation.new(:branch, check.value, truthy.value, falsey.value)
  end

  rule 'compose_list : COMPOSE NAME
  | COMPOSE math_compose
  | COMPOSE branch_compose
  | COMPOSE NAME compose_list
  | COMPOSE math_compose compose_list
  | COMPOSE branch_compose compose_list'\
  do |compose_list, _compose, name, list|
    compose_list.value = Array(name.value) + Array(list&.value)
  end

  rule 'expression : expression compose_list'\
  do |expression, list_expression, composers|
    expression.value = Operation.new(:compose, list_expression.value, composers.value)
  end

  # This is currently broken
  rule 'math_compose : ANON_FUNC "+" NUMBER
  | ANON_FUNC "-" NUMBER
  | ANON_FUNC "*" NUMBER
  | ANON_FUNC "/" NUMBER
  | ANON_FUNC "%" NUMBER
  | ANON_FUNC "^" NUMBER'\
  do |compose, _function, operator, number|
    expression = Operation.new(operator.value.to_sym, Operation.new(:lookup, '___'), Operation.new(:number, number.value.to_i))
    compose.value = Operation.new(:function, '___', expression)
  end
end
