class Interpreter
  def initialize
    @names = {}
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :number then number(*tree.arguments)
    when :+ then add(*tree.arguments) 
    when :- then subtract(*tree.arguments) 
    when :* then multiply(*tree.arguments) 
    when :/ then divide(*tree.arguments)
    when :% then remainder(*tree.arguments)
    when :** then exponentiate(*tree.arguments)    
    else
      puts "I don't know how to handle operation '#{tree.operation}'!"
    end
  end

  def number(number)
    number.to_i
  end

  def add(value1, value2)
    evaluate(value1) + evaluate(value2)
  end 

  def subtract(value1, value2)
    evaluate(value1) - evaluate(value2)
  end 

  def multiply(value1, value2)
    evaluate(value1) * evaluate(value2)
  end 

  def divide(value1, value2)
    evaluate(value1) / evaluate(value2)

  end 

  def remainder(value1, value2)
    evaluate(value1) % evaluate(value2)
  end 

  def exponentiate(value1, value2)
    evaluate(value1) ** evaluate(value2)
  end 
end
