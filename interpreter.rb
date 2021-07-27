require "bigdecimal"

class Interpreter
  def initialize
    @names = {}
  end

  def evaluate(tree)
    puts "Interpreter: evaluate(tree): tree: #{tree.inspect}"
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :assign then assign(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :number then number(*tree.arguments)
    end
  end

  def assign(name, value)
    puts "Interpreter: assign => name: #{name}, value: #{value}"
    @names[name.value] = evaluate(value)
  end

  def lookup(name)
    puts "Interpreter: name: #{name.inspect}"
    @names[name.value]
  end

  def number(number)
    puts "Interpreter: number => #{number.inspect}"
    BigDecimal(number)
  end
end
