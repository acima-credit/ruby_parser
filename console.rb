require "rly"
require "readline"
require "./lexer"
require "./parser"
require './interpreter'

parser = Parser.new(Lexer.new)
interpreter = Interpreter.new

puts "Tokens"
puts "------"
Lexer.tokens.each { |name, regex| puts "#{name}: #{regex}" }
puts

puts "Rules"
puts "-----"
Parser.rules.each { |rule, _| puts rule }
puts

puts "'exit' to quit"
puts

while (buffer = Readline.readline("> ", true))
  parse_tree = parser.parse(buffer)
  puts "Console: parser has parsed buffer, returning parse_tree: #{parse_tree}"
  puts interpreter.evaluate(parse_tree)
end
