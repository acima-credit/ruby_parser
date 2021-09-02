# frozen_string_literal: true

require 'rly'
require 'colorize'
class Lexer < Rly::Lex
  literals ""
  ignore " \t\n\r"

  def self.log(msg)
    $stdout.puts "Lexer: #{msg}"
    $stdout.flush
  end

  def log(msg)
    self.class.log(msg)
  end

  def self.logged_token(name, regexp)
    token name, regexp do |tok|
      log "'#{tok}' --> (#{tok.to_s}, #{tok.type})"
      tok
    end
  end

  # language keywords
  logged_token :RING, /ring/  # -> multiply x and y ~ x * y ;;; ring multiply with 3 and 5
  logged_token :WITH, /with/

  logged_token :NUMBER, /\d+\.?\d*/
  logged_token :CLOSE_TOOLBOX, /exit/
  logged_token :NAME, /[a-zA-Z]+/
  logged_token :KERF, /\=/
  logged_token :FLATHEAD, /\-/
  logged_token :PHILLIPS, /\+/
  logged_token :TORX, /\*/
  logged_token :RAZOR, /\//
  logged_token :SQUARE, /\^/
  logged_token :LEFT_HOOK, /\(/
  logged_token :RIGHT_HOOK, /\)/
  logged_token :PULLEY, /\%/
  logged_token :SCREW, /\~/
  logged_token :RIVET, /\,/    # -> delimiter for function parameters 

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
