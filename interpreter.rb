class Interpreter
  class Scope
    attr_accessor :name

    def initialize(name = {})
      @name = name
    end

    def dump
      self.class.new(name.dump)
    end
  end

  class Function
    attr_accessor :params, :body

    def initialize(params:, body:)
      @params = params,
      @body = body
    end
  end


  def initialize
    @stack = [Scope.new]
  end

  def current_scope
    @stack.last
  end

  # def add_to_stack()
  #   @stack.push()
  # end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :assign then assign(*tree.arguments)
    when :number then number(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :function then function(*tree.arguments)
    when :+ then addition(*tree.arguments)
    when :- then subtraction(*tree.arguments)
    when :* then multiply(*tree.arguments)
    when :/ then divide(*tree.arguments)
    when :% then modulo(*tree.arguments)
    when :^ then exponent(*tree.arguments)
    else
      puts "I don't know how to handle operation '#{tree.operation}'!"
    end
  end

  def function(body)
    Function.new(params: {}, body: body)
  end

  def assign(var_name, expression)
    current_scope.name[var_name] = evaluate(expression)
  end

  def number(number)
    number.to_i
  end
#a = $() ~> 1 + 2
  def lookup(name)
    value = current_scope.name[name]
    return evaluate(value.body) if value.is_a?(Function)
  end

  def addition(value_1, value_2)
    evaluate(value_1) + evaluate(value_2)
  end

  def subtraction(value_1, value_2)
    evaluate(value_1) - evaluate(value_2)
  end

  def multiply(value_1, value_2)
    evaluate(value_1) * evaluate(value_2)
  end

  def divide(value_1, value_2)
    evaluate(value_1) / evaluate(value_2)
  end

  def modulo(value_1, value_2)
    evaluate(value_1) % evaluate(value_2)
  end

  def exponent(value_1, value_2)
    evaluate(value_1) ** evaluate(value_2)
  end
end

