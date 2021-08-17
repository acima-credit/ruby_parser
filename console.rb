# frozen_string_literal: true

require 'rly'
require 'pry'
require 'colorize'
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

while (buffer = Readline.readline('▶ '.green, true))
  parse_tree = parser.parse(buffer)
  puts interpreter.evaluate(parse_tree)
end
