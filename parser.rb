class Operation
	attr_reader :operation, :arguments

	def initialize(operation, *arguments)
		@operation = operation
		@arguments = arguments
	end

	def to_s
		"#{operation} : #{arguments.join(', ')}"
	end
end

class Parser < Rly::Yacc
	rule 'statement : NAME "=" expression' do |statement, name, _, expression|
		statement.value = Operation.new(:assign, name, expression)
	end

	rule 'expression : NUMBER' do |expression, number|
		expression.value = Operation.new(:number, number)
	end
end