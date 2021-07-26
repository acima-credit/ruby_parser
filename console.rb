require "rly"
require "readline"
require "./lexer"
require "./parser"

parser = Parser.new(Lexer.new)

puts "Tokens"
puts "------"
Lexer.tokens.each { |name, regex| puts "#{name}: #{regex}" }
puts

puts "Rules"
puts "-----"
Parser.rules.each { |rule, _| puts rule }
puts

while (buffer = Readline.readline("> ", true))
  parse_tree = parser.parse(buffer)
  puts parse_tree
end
