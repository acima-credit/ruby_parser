# frozen_string_literal: true

require 'rly'
require 'colorize'
class Lexer < Rly::Lex
  literals ""
  ignore " \t\n\r"

  def self.log(msg)
    $stdout.puts "Lexer: #{msg}".black.on_green
    $stdout.flush
  end
  def log(msg)
    self.class.log(msg)
  end

  def self.logged_token(name, regexp)
    token name, regexp do |tok|
      log "'#{tok}' --> #{tok.to_s}"
      tok
    end
  end

  logged_token :NUMBER, /\d+\.?\d*/
  logged_token :CLOSE_TOOLBOX, /exit/
  logged_token :NAME, /[a-zA-Z]+/
  logged_token :KERF, /\=/
  logged_token :FLATHEAD, /\-/
  logged_token :PHILLIPS, /\+/
  logged_token :TORX, /\*/
  logged_token :RAZOR, /\//
  logged_token :SQUARE, /\^/


  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
