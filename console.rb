# frozen_string_literal: true

require 'rly'
require 'pry'
require 'readline'
require './lexer'
require './parser'
require './interpreter'

parser = Parser.new(Lexer.new)
interpreter = Interpreter.new

while (buffer = Readline.readline('> ', true))
  parse_tree = parser.parse(buffer)
  puts parse_tree
  puts interpreter.evaluate(parse_tree)
end
