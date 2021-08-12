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
  
  rule 'expression : "(" expression ")"' do |expression, _left, exp, _right|
    expression.value = exp.value
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

  rule 'parameter : NAME'\
  do |parameter, name|
    parameter.value = name.value
  end

  rule 'parameter_list : parameter | parameter "|" parameter_list'\
  do |parameter_list, param, _pipe, list|
    parameter_list.value = Array(param.value) + Array(list&.value)
  end

  rule 'expression : "(" ")" FUNCTION expression' do |expression, _lp, _rp, _func, exp|
    expression.value = Operation.new(:function, exp.value)
  end

  rule 'expression : "(" parameter_list ")" FUNCTION expression'\
  do |expression, _lp, params, _rp, _func, exp|
    expression.value = Operation.new(:function, exp.value, params.value)
  end

  rule 'expression_list : expression | expression "|" expression_list'\
  do |expression_list, param, _pipe, list|
    expression_list.value = Array(param.value) + Array(list&.value)
  end  

  rule 'expression : "(" expression_list ")" CALL NAME'\
  do |expression, _lp, list, _rp, _call, name|
    expression.value = Operation.new(:call, list.value, name.value)
  end
end


# (a | b) => 1 + a + b
# (1 | 2 | 3) >> multiply