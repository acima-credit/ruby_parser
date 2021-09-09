# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  literals "+-*/%^(),!><?:&|"
  ignore " \t\n\r"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z]+/
  token :FUNCTION, /\$/
  token :FUNCTION_ARROW, /~>/
  token :EQ, /\=\=/
  token :NOT_EQ, /\!\=/
  token :GT, /\>[^\=]/
  token :LT, /\<[^\=]/
  token :GET, /\>\=/
  token :LET, /\<\=/
  token :TERNARY_QUESTION, /\?/
  token :TERNARY_COLON, /\:/
  token :AND, /\&\&/
  token :OR, /\|\|/
  token :ASSIGMENT, /\=/

  alias_method :raw_next, :next

  def next
    token = raw_next 
    puts token.inspect
    token
  end

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end


# NUMBER arithmetic_f NUMBER
# arithmetic_f NUMBER  NUMBER
# NUMBER  NUMBER arithmetic_f

# 5 + 5
# + 5 5
# 5 5 +
