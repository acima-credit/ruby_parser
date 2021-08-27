# frozen_string_literal: true

require 'rly'

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

class Lexer < Rly::Lex
  literals "+-*/%=^()"
  ignore " \t\n\r"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z_]\w*/ # variable names must be at least 3 characters
  token :COMMENT, /#.*/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end




'statement : expression'

def statement(token)
  expression(token)
end

def expression(token)
  case token
  when expression "+" expression
  when NUMBER
  end
end
