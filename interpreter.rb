class Interpreter
  def initialize
    @names = {}
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :number then number(*tree.arguments)
    when :+ then add(*tree.arguments)  
    else
      puts "I don't know how to handle operation '#{tree.operation}'!"
    end
  end

  def number(number)
    number
  end

  def add(value1, value2)
    evaluate(value1) + evaluate(value2)
  end 
end
