class Interpreter
  Error = Class.new(StandardError)
  UnknownOperationError = Class.new(Error)
  BadDivisionError = Class.new(Error)

  class Scope
    attr_accessor :names

    def initialize(names = {})
      @names = names
    end

    def dup
      self.class.new(names.dup)
    end
  end

  attr_accessor :names

  def initialize
    @names = {}
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :number then number(*tree.arguments)
    when :assignment then assign(*tree.arguments)
    when :function then function(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :+ then add(*tree.arguments)
    when :- then subtract(*tree.arguments)
    when :* then multiply(*tree.arguments)
    when :% then modulo(*tree.arguments)
    when :/ then divide(*tree.arguments)
    when :^ then exponentiate(*tree.arguments)
    when :negate then negate(*tree.arguments)
    else
      raise UnknownOperationError, tree.operation
    end
  rescue Error => e
    puts "Error: #{e.class} - #{e.message}"
  rescue => e
    puts "Oops: #{e.class} - #{e.message}"    
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

  def function(expression, params=[])
    { expression: expression, params: params }
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

  def modulo(value1, value2)
    evaluate(value1) % evaluate(value2)
  end

  def divide(value1, value2)
    evaluate(value1) / evaluate(value2)

  rescue ZeroDivisionError
    raise BadDivisionError, "Can't divide by 0"
  end

  def exponentiate(value1, value2)
    evaluate(value1) ** evaluate(value2)
  end

  def negate(value1)
    evaluate(value1) * -1
  end
end
