
def arithmatic(expression, other_expression)
  case other_expression
  when (+ other_expression)
    expression + other_expression
  when (- other_expression)
    expression - other_expression
  end
end





