# frozen_string_literal: true

require 'rly'
require 'colorize'

# Lexer  ->  Parser  ->  Interpreter
#  ^^          ^^            ^^ (Compiler)
# "..."


# Raw (Source) Text:
# "function multiply(x, y) { x * y; }"

# FUNCTION_KEYWORD NAME LEFT_PAREN NAME COMMA NAME RIGHT_PAREN LEFT_BRACE ...

# source text -> Lexer -> tokens -> Parser -> syntax tree -> Interpreter

# Source        | Lexer                             | Parser                           | Interpreter
# > 3 + 2       | NUMBER("3") PLUS("+") NUMBER("2") | (:+, (:number, 3), (:number, 2)) | 5
# > (1+1)*3     |
# > 3*(1-1)     |
# > abc = 123   |
# > abc * 2     |

class Rly::LexToken
  def to_str
    "<#LexToken type=#{type}, value=#{value}>"
  end
end

class Lexer < Rly::Lex
  literals ""
  ignore " \t\n\r"

  class <<self
    def log(msg)
      $stdout.puts "Lexer: #{msg}".black.on_green
      $stdout.flush
    end

    def logged_token(name, regexp)
      token name, regexp do |tok|
        log "'#{tok}' -> #{tok.to_str}"
        tok
      end
    end
  end

  def log(msg)
    self.class.log msg
  end

  alias_method(:orig_next, :next)

  def next
    log "Lex.next() called"
    orig_next
  end

  logged_token :PLUS, /\+/
  logged_token :HYPHEN, /\-/
  logged_token :STAR, /\*/
  logged_token :SLASH, /\//
  logged_token :PERCENT, /%/
  logged_token :CARET, /\^/
  logged_token :EQUAL, /\=/
  logged_token :LPAREN, /\(/
  logged_token :RPAREN, /\)/
  logged_token :NUMBER, /\d+\.?\d*/
  logged_token :NAME, /[a-zA-Z_]\w{2,}/ # variable names must be at least 3 characters

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end
