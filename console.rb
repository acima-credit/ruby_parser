# frozen_string_literal: true

require 'rly'
require 'pry'
require 'readline'
require './lexer'
require './parser'
require './interpreter'

parser = Parser.new(Lexer.new)
interpreter = Interpreter.new

puts 'Literals'
puts '--------'
puts Lexer.literals_list.chars.join(' ')
puts

puts 'Tokens'
puts '------'
Lexer.tokens.each { |name, regex| puts "#{name}: #{regex}" }
puts

puts 'Rules'
puts '-----'
Parser.rules.each { |rule, _| puts rule }
puts

puts "'exit' to quit"
puts

while (buffer = Readline.readline('> ', true))
  parse_tree = parser.parse(buffer)
  puts interpreter.evaluate(parse_tree)
end
