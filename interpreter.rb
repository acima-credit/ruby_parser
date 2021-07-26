require "bigdecimal"
class Interpreter
	def initialize
		@names = {}
	end 

	def evaluate(tree)
		puts "tree in inter #{tree}"
		case tree.operation
		when :evaluate then evaluate(*tree.arguments)
		when :assign then assign(*tree.arguments)
		when :lookup then lookup(*tree.arguments)
		when :number then number(*tree.arguments)
		end
	end

	def assign(name, value)
		@names[name.value] = evaluate(value)
	end

	def lookup(token)
		@names[token.value]
	end

	def number(token)
		BigDecimal(token.value).to_i
	end
end
