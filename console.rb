# frozen_string_literal: true

require 'rly'
require 'pry'
require 'readline'
require 'colorize'
require './lexer'
require './parser'
require './interpreter'

parser = Parser.new(Lexer.new)
interpreter = Interpreter.new

puts 'Literals'.blue
puts ('-' * 32).blue
puts Lexer.literals_list.chars.join(' ')
puts

puts 'Tokens'.blue
puts ('-' * 32).blue
Lexer.tokens.each { |name, regex| puts "#{name}: #{regex}" }
puts

puts 'Rules'.blue
puts ('-' * 32).blue
Parser.rules.each { |rule, _| puts rule }
puts

puts "#{'exit'.yellow} to quit"
puts

while (buffer = Readline.readline('> ', true))
  parse_tree = parser.parse(buffer)
  puts parse_tree
  puts interpreter.evaluate(parse_tree).to_s.green
end
