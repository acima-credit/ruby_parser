class Interpreter
  Error = Class.new(StandardError)
  UnknownOperationError = Class.new(Error)

  # class Scope
  #   attr_accessor :names

  #   def initialize(names = {})
  #     @names = names
  #   end

  #   def dup
  #     self.class.new(names.dup)
  #   end
  # end

  attr_accessor :names

  def initialize
    @names = {}
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :number then number(*tree.arguments)
    when :assignment then assign(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :+ then add(*tree.arguments)
    when :- then subtract(*tree.arguments)
    else
      raise UnknownOperationError, tree.operation
    end
  rescue Error => e
    puts "Error: #{e.class} - #{e.message}"
  rescue => e
    puts "Oops: #{e.message}"    
  end

  def number(number)
    number
  end

  def assign(name, value)
    names[name] = evaluate(value)
  end

  def lookup(name)
    names[name]
  end

  def add(value1, value2)
    evaluate(value1) + evaluate(value2)
  end

  def subtract(value1, value2)
    evaluate(value1) - evaluate(value2)
  end
end
