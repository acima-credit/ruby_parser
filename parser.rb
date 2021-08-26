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
  precedence :left, '*', '/'
  precedence :left, '%', '^'

  rule 'statement : NAME "=" expression' do |statement, name, equals, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  rule 'statement : condition_list' do |statement, expression|
    statement.value = Operation.new(:condition_list, expression.value)
  end

  rule 'expression : FUNCTION "(" ")" FUNCTION_ARROW expression'  do |expression, _function, _left_parentesis, _right_parentesis, _equal, body_function|
    expression.value = Operation.new(:function, nil, body_function.value)
  end

  rule 'expression : FUNCTION "(" parameter_list ")" FUNCTION_ARROW expression'  do |expression, _function, _left_parentesis, parameter_list, _right_parentesis, _equal, body_function|
    expression.value = Operation.new(:function, parameter_list.value, body_function.value)
  end

  rule 'parameter : NAME' do |parameter, name|
    parameter.value = name.value
  end

  rule 'parameter_list : parameter | parameter "," parameter_list ' do |parameter_list, parameter, _comma, list|
    parameter_list.value = Array(parameter.value) + Array(list&.value)
  end

  rule 'expression : NUMBER' do |expression, number|
    expression.value = Operation.new(:number, number.value)
  end

  rule 'expression : NAME' do |expression, name|
    exit(0) if ["exit", "quit"].include?(name.value)
    expression.value = Operation.new(:lookup, name.value)
  end

  rule 'expression_list : expression | expression "," expression_list' do |expression_list, expression, _comma, list|
    expression_list.value = Array(expression.value) + Array(list&.value)
  end

  rule 'expression : NAME "(" expression_list ")"' do |expression, name, _lpar, parameter_expression, _rpar|
    expression.value = Operation.new(:evaluate_function, name, parameter_expression.value)
  end

  rule 'expression : expression "+" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:+, number_a.value, number_b.value)
  end

  rule 'expression : expression "-" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:-, number_a.value, number_b.value)
  end

  rule 'expression : expression "*" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:*, number_a.value, number_b.value)
  end

  rule 'expression : expression "/" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:/, number_a.value, number_b.value)
  end

  rule 'expression : expression "%" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:%, number_a.value, number_b.value)
  end

  rule 'expression : expression "^" expression' do |expression, number_a, operator, number_b|
    expression.value = Operation.new(:^, number_a.value, number_b.value)
  end


  # conditionals

  # if <conditional statement> then <>  else end

  rule 'expression : expression EQ expression' do |expression, expression_a, _equals, expression_b|
    expression.value = Operation.new(:==, expression_a.value, expression_b.value)
  end

  rule 'expression : expression NOT_EQ expression' do |expression, expression_a, _not_equals, expression_b|
    expression.value = Operation.new(:!=, expression_a.value, expression_b.value)
  end

  rule 'expression : expression GT expression' do |expression, expression_a, _greater_than, expression_b|
    expression.value = Operation.new(:>, expression_a.value, expression_b.value)
  end

  rule 'expression : expression LT expression' do |expression, expression_a, _lower_than, expression_b|
    expression.value = Operation.new(:<, expression_a.value, expression_b.value)
  end

  rule 'expression : expression GET expression' do |expression, expression_a, _greater_equal_than, expression_b|
    expression.value = Operation.new(:>=, expression_a.value, expression_b.value)
  end

  rule 'expression : expression LET expression' do |expression, expression_a, _lower_equal_than, expression_b|
    expression.value = Operation.new(:<=, expression_a.value, expression_b.value)
  end

  rule 'expression : expression TERNARY_QUESTION expression TERNARY_COLON expression' do |expression, expression_a, _question, expression_b, _colon, expression_c|
    expression.value = Operation.new(:ternary, expression_a.value, expression_b.value, expression_c.value)
  end

  rule 'condition_list : expression | expression AND condition_list | expression OR condition_list' do |condition_list, condition, condition_operator, list|
    if(list.nil?)
      condition_list.value = condition.value
    else
      if condition_operator.value == '&&'
        condition_list.value = Operation.new(:and, condition.value, list.value)
      else
        condition_list.value = Operation.new(:or, condition.value, list.value)
      end
    end
  end

  # rule 'condition_list : condition | condition OR condition_list' do |condition_list, condition, _or, list|
  #   if(list.nil?)
  #     condition_list.value = condition.value
  #   else
  #     condition_list.value = Operation.new(:or, condition.value, list.value)
  #   end
  # end
end
