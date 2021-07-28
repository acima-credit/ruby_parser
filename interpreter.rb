require_relative 'scope'

class Interpreter
  def initialize
    # don't access scopes directly; use current_scope instead
    @scopes = []
    push_scope
  end

  def push_scope
    @scopes << Scope.new
  end

  def current_scope
    @scopes.last
  end

  def pop_scope
    # TODO: freak out if scope.size == 1, don't pop me bro
    @scopes.pop
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

    # boolean comparisons
    when :== then self.==(*tree.arguments)
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

  def ==(a, b)
    evaluate(a) <=> evaluate(b)
  end

  def assign(name, value)
    current_scope[name] = evaluate(value)
  end

  def lookup(name)
    current_scope[name]
  end

  def number(number)
    number
  end

  def negate(value)
    -1 * evaluate(value)
  end
end
