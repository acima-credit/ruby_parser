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
  rescue
    "that didn't work!!!"
  end

  def number(number)
    number.to_i
  end

  def add(a, b)
    evaluate(a) + evaluate(b)
  end

  # def subtract(a, b)
  #   evaluate(a) + evaluate(b)
  # end
  
  # def multiply(a, b)
  #   evaluate(a) + evaluate(b)
  # end
  
  # def divide(a, b)
  #   evaluate(a) + evaluate(b)
  # end
end
