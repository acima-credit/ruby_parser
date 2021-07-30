# frozen_string_literal: true

require 'rly'
require 'pry'
require 'optimist'
require 'readline'
require './lexer'
require './parser'
require './interpreter'

if $0==__FILE__
  opts = Optimist::options do
    opt :verbose, "Verbose messaging from all components (0=none, 1=lexer, 2=parser, 4=interpreter)", type: :integer, default: 0, short: "v"
  end

  opts[:verboselexer] = true if (opts[:verbose] & 1) == 1
  opts[:verboseparser] = true if (opts[:verbose] & 2) == 2
  opts[:verboseinterpreter] = true if (opts[:verbose] & 4) == 4

  lexer = Lexer.new(verbose: opts[:verboselexer])
  parser = Parser.new(lexer: lexer, verbose: opts[:verboseparser])
  interpreter = Interpreter.new(verbose: opts[:verboseinterpreter])

  if lexer.verbose
    puts 'Literals'
    puts '--------'
    puts Lexer.literals_list.chars.join(' ')
    puts

    puts 'Tokens'
    puts '------'
    Lexer.tokens.each { |name, regex| puts "#{name}: #{regex}" }
    puts
  end

  if parser.verbose
    puts 'Rules'
    puts '-----'
    Parser.rules.each { |rule, _| puts rule }
    puts
  end

  puts "'exit' to quit"
  puts

  while (buffer = Readline.readline('🎸  ', true))
    parse_tree = parser.parse(buffer)
    puts parse_tree if parser.verbose
    puts interpreter.evaluate(parse_tree)
  end
end
