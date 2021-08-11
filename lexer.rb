# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  literals "+-*/%^="
  ignore " \t\n\r"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z]+/

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
