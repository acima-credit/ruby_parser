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
  precedence :right, :UMINUS

  rule 'statement : NAME "=" expression' do |statement, name, _, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'expression : "-" expression %prec UMINUS' do |expression, _neg, exp|
    expression.value = Operation.new(:negate, exp.value)
  end

  rule 'expression : "(" expression ")"' do |expression, _lparen, exp, _rparen|
    expression.value = exp.value
  end

  rule 'expression : expression "+" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:+, a.value, b.value)
  end

  rule 'expression : expression "-" expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:-, a.value, b.value)
  end

  rule 'expression : expression "*" expression' do |expression, a, _operation, b|
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
    exit(0) if %w[quit exit].include?(name.value)

    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, number.value.to_i)
  end

  rule 'parameter : NAME
                  | FNAME ' do |parameter, name|
    parameter.value = name.value
  end

  rule 'parameter_list : parameter
                       | parameter "," parameter_list' do |parameter_list, param, _comma, list|
    parameter_list.value = Array(param.value) + Array(list&.value)
  end

  rule 'expression_list : expression
                        | expression "," expression_list' do |expression_list, exp, _comma, list|
    expression_list.value = Array(exp.value) + Array(list&.value)
  end

  rule 'expression : LAMBDA "\" parameter_list "\" expression
                   | LAMBDA "." "." "." expression' do |expression, _lambda, _, params, _, exp|
    list = params.value == '.' ? [] : params.value
    expression.value = Operation.new(:function, list, exp.value)
  end

  rule 'expression : "{" expression_list "}"' do |expression, _lcurly, expression_list, _rcurly|
    expression.value = Operation.new(:list, expression_list.value)
  end

  rule 'expression : NAME "[" expression_list "]"' do |expression, name, _lbracket, list, _rbracket|
    expression.value = Operation.new(:lookup, name.value, list.value)
  end
end


# foo = λ\ƒfunc, num\ func[num]

# bar = λ\baz\ baz + 1

# foo[bar, 3]

