class Interpreter
  class Scope
    attr_accessor :names

    def initialize(names = {})
      @names = names
      @loop_counter = 0
      @loop_statements = []
    end

    def dup
      self.class.new(names.dup)
    end
  end

  class Function
    attr_accessor :params, :expression

    def initialize(params, expression)
      @params = params
      @expression = expression
    end

    def dup
      self.class.new(params.dup, expression.dup)
    end
  end

  def initialize
    @call_stack = [Scope.new]
  end

  def current_scope
    @call_stack.last
  end

  def push_stack
    @call_stack.push(current_scope.dup)
  end

  def pop_stack
    @call_stack.pop
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :assign then assign(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :number then number(*tree.arguments)
    when :negate then negate(*tree.arguments)
    when :function then function(*tree.arguments)
    when :list then list(*tree.arguments)
    # for binary operations, evaluate each arg (remember we only ever get them in pairs)
    # then do the operations on them, e.g. "a op b"
    #
    # when :+,:-,:*,:/ then tree.arguments.map(&method(:evaluate)).reduce(&tree.operation)

    # ^^ this is logically equivalent to the simpler, explicit code of:
    when :+ then self.+(*tree.arguments)
    when :- then self.-(*tree.arguments)
    when :* then self.*(*tree.arguments)
    when :/ then self./(*tree.arguments)
    when :% then self.%(*tree.arguments)
    when :^ then self.^(*tree.arguments)
    else
      puts "I don't know how to handle operation '#{tree.operation}'!"
    end
  end

  def +(a, b)
    object_a = evaluate(a)
    # Need to figure out how to get 2 list operation to interact
    if object_a.is_a?
      result = object_a.map { |index| Operation.new(:number, evaluate(index) + evaluate(b)) }
      Operation.new(:list, result)
    else
      object_a + evaluate(b)
    end
  end

  def -(a, b)
    evaluate(a) - evaluate(b)
  end

  def *(a, b)
    evaluate(a) * evaluate(b)
  end

  def /(a, b)
    evaluate(a) / evaluate(b)
  end

  def %(a, b)
    evaluate(a) % evaluate(b)
  end

  def ^(a, b)
    evaluate(a) ** evaluate(b)
  end

  def assign(name, value)
    current_scope.names[name] = evaluate(value)
  end

  def lookup(name, values = [])
    value = current_scope.names[name]

    return evaluate_function(value, values) if value.is_a? Function

    value
  end

  def function_lookup(operation)
    current_scope.names[operation.arguments.first]
  end

  def number(number)
    number
  end

  def negate(value)
    -1 * evaluate(value)
  end

  def function(params, expression)
    Function.new(params, expression)
  end

  def evaluate_function(function, values)
    within_new_scope do
      function.params.each_with_index do |param, index|
        if param.chars.first == "ƒ"
          function_name = param[1..-1]
          current_scope.names[function_name] = function_lookup(values[index])
        else
          assign(param, values[index])
        end
      end
      evaluate(function.expression)
    end
  end

  def within_new_scope
    return unless block_given?

    push_stack
    yield.tap { pop_stack }
  end

  def list(array)
    Operation.new(:list, array)
  end
end
