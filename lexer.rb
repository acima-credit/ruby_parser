# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  literals "+-*/%=^()|,"
  ignore " \t\n"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z_]\w{2,}/ # variable names must be at least 3 characters
  token :LAMBDA, /λ/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
