# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  literals '+-*/%:^()\\,.[]{}~|'
  ignore " \t\n"

  token :EXIT, /exit/
  token :QUIT, /quit/
  token :HISTORY, /history/
  token :CLEAR, /clear/
  token :SAVE, /save/
  token :LOAD, /load/
  token :HALT, /halt/
  token :GTE, /><>/
  token :LTE, /<></
  token :EQ, /<>/
  token :NEQ, /></
  token :LT, /</
  token :GT, />/
  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z_]+/
  token :FNAME, /ƒ[a-zA-Z_]+/
  token :LAMBDA, /λ/
  token :COMPOSE, /∘/
  token :BRANCH, /⌥/
  token :ANON_FUNC, /ƒ/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
