# frozen_string_literal: true

require 'rly'
class Lexer < Rly::Lex
  literals ""
  ignore " \t\n\r"

  token :NUMBER, /\d+\.?\d*/
  token :LOOK, /look/
  token :NAME, /[a-zA-Z_]/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
