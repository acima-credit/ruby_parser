require "rly"
require "readline"
require "./lexer"
require "./parser"

parser = Parser.new(Lexer.new)

while buffer = Readline.readline("> ", true)
  parse_tree = parser.parse(buffer)
  puts parse_tree
end
