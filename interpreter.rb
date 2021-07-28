class Interpreter
  def initialize
    @names = {}
  end

  def evaluate(tree)
    case tree.operation
    when :evaluate then evaluate(*tree.arguments)
    when :assign then assign(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :number then number(*tree.arguments)
    when :negate then negate(*tree.arguments)
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
    evaluate(a) + evaluate(b)
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
    @names[name] = evaluate(value)
  end

  def lookup(name)
    @names[name]
  end

  def number(number)
    number
  end

  def negate(value)
    -1 * evaluate(value)
  end
end
