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
  attr_reader :verbose

  def initialize(lexer:, verbose: false)
    @verbose = verbose
    puts "Parser: Verbose parsing." if verbose
    super(lexer)
  end

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

  rule 'expression : expression EQUALITY expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:==, a.value, b.value)
  end

  rule 'expression : expression INEQUALITY expression' do |expression, a, _operation, b|
    expression.value = Operation.new(:!=, a.value, b.value)
  end

  rule 'arg_list : NAME 
                 | NAME "," arg_list' do |arg_list, name, _, agr_list|
    puts "Parser: rule #{arg_list}, #{name}, #{agr_list}"
  end

  # &my_func(a, b) a + b
  # our functions needs to be at least 3 letters name
  rule 'expression : FUNCTION NAME "(" arg_list ")" expression' do |expression, _function_token, function_name, _, arg_list, _, function_body|
    expression.value = Operation.new(:function, function_name, function_body.value)
  end
end
