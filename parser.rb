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
  precedence :left, '?'
  precedence :left, ':'
  precedence :left, '&&', '||'
  precedence :left, '<', '>', '<=', '>=', '==', '!='
  precedence :left, '+', '-'
  precedence :left, '*', '/'
  precedence :left, '%', '^'
  
  rule 'statement : NAME "=" expression' do |statement, name, equals, expression|
    statement.value = Operation.new(:assign, name.value, expression.value)
  end

  rule 'statement : expression' do |statement, expression|
    statement.value = Operation.new(:evaluate, expression.value)
  end

  # rule 'expression : condition_list' do |statement, expression|
  #   statement.value = Operation.new(:condition_list, expression.value)
  # end

  rule 'expression : "(" expression ")"' do |expression, _left, expression_a, _right|
    expression.value = expression_a.value
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
  # https://www.lysator.liu.se/c/ANSI-C-grammar-y.html

  # if <conditional statement> then <>  else end

  rule 'equality_expression : relational_condition' do |equality_expression, relational_condition|
    equality_expression.value = Operation.new(:evaluate, relational_condition.value)
  end

  rule 'equality_expression : equality_expression EQ relational_condition' do |expression, expression_a, _equals, expression_b|
    expression.value = Operation.new(:==, expression_a.value, expression_b.value)
  end

  rule 'equality_expression : equality_expression NOT_EQ relational_condition' do |expression, expression_a, _not_equals, expression_b|
    expression.value = Operation.new(:!=, expression_a.value, expression_b.value)
  end

  rule 'relational_condition : expression GT expression' do |expression, expression_a, _greater_than, expression_b|
    expression.value = Operation.new(:>, expression_a.value, expression_b.value)
  end

  rule 'relational_condition : expression LT expression' do |expression, expression_a, _lower_than, expression_b|
    expression.value = Operation.new(:<, expression_a.value, expression_b.value)
  end

  rule 'relational_condition : expression GET expression' do |expression, expression_a, _greater_equal_than, expression_b|
    expression.value = Operation.new(:>=, expression_a.value, expression_b.value)
  end

  rule 'relational_condition : expression LET expression' do |expression, expression_a, _lower_equal_than, expression_b|
    expression.value = Operation.new(:<=, expression_a.value, expression_b.value)
  end
  # 1 > 2 && 3 > 4 ? 5 : 6
  # condition_list interfers with the ternary rule. FIX IT

  rule 'and_expression : equality_expression' do |and_expression, equality_expression|
    and_expression.value = Operation.new(:evaluate, equality_expression.value)
  end

  rule 'and_expression : and_expression AND equality_expression' do |and_expression, and_expression_2, _and, equality_expression|
    and_expression.value = Operation.new(:and, and_expression_2.value, equality_expression.value)
  end

  rule 'or_expression : and_expression' do |or_expression, and_expression|
    or_expression.value = Operation.new(:evaluate, and_expression.value)
  end

  rule 'or_expression : or_expression OR and_expression' do |or_expression, or_expression_2, _or, and_expression|
    or_expression.value = Operation.new(:or, or_expression_2.value, and_expression.value)
  end

  # rule 'condition_list : condition AND condition_list | condition OR condition_list | condition ' do |condition_list, condition, condition_operator, list|
  #   # binding.pry
  #   if(list.nil?)
  #     condition_list.value = condition.value
  #   else
  #     if condition_operator.value == '&&'
  #       condition_list.value = Operation.new(:and, condition.value, list.value)
  #     else
  #       condition_list.value = Operation.new(:or, condition.value, list.value)
  #     end
  #   end
  # end

  # rule 'condition_list : condition AND condition_list | condition ' do |condition_list, condition, _condition_operator, list|
  #   # binding.pry
  #   condition_list.value = Operation.new(:and, condition.value, list.value)
  # end

  rule 'ternary : or_expression' do |ternary, or_expression|
    ternary.value = Operation.new(:evaluate, or_expression.value)
  end

  rule 'ternary : or_expression "?" expression ":" ternary' do |ternary, or_expression, _question, expression, _colon, ternary_2|
    ternary.value = Operation.new(:ternary, or_expression.value, expression.value, ternary_2.value)
  end

  rule 'expression : ternary' do |expression, ternary|
    expression.value = Operation.new(:evaluate, ternary.value)
  end
  # rule 'condition_list : condition | condition OR condition_list' do |condition_list, condition, _or, list|
  #   if(list.nil?)
  #     condition_list.value = condition.value
  #   else
  #     condition_list.value = Operation.new(:or, condition.value, list.value)
  #   end
  # end
end
