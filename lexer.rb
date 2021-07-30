# frozen_string_literal: true

require 'rly'

class Lexer < Rly::Lex
  attr_reader :verbose

  def initialize(verbose: false)
    @verbose = verbose
    puts "Lexer: Verbose lexing." if verbose
    super()
  end

  literals "+-*/%=^(),"
  ignore " \t\n"

  token :NUMBER, /\d+\.?\d*/
  token :NAME, /[a-zA-Z_]\w{2,}/ # variable names must be at least 3 characters
  token :EQUALITY, /((!!)+=)|==+/
  token :INEQUALITY, /!(!!)*=+/
  token :FUNCTION,  /&/

  on_error do |t|
    puts "Illegal character #{t.value}"
    t.lexer.pos += 1
    nil
  end
end


# # define function
# &abc(xyz, qpr) (xyz * qpr) + 7

# # call function
# abc((3+2), def(5))
# NAME "(" NUMBER(3) "," NUMBER(5) ")"

# 22
