# frozen_string_literal: true

require 'rly'
class Lexer < Rly::Lex
  literals ""
  ignore " \t\n\r"

  token :HISTORY, /history/
  token :LOOK, /look/
  token :OPEN, /open/
  token :CLOSE, /close/
  token :INVOKE, /invoke/
  token :CRAFT, /craft/
  token :EQUIP, /equip/
  token :INVENTORY, /inventory/
  token :GO, /go/
  token :SAVE, /save/
  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z_]+/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
