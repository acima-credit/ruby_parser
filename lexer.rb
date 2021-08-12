# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  literals "+-*/%^=(),|"
  ignore " \t\n\r"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z]+/
  token :FUNCTION, /\=\>/
  token :CALL , /\>\>/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
