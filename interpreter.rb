class Interpreter
  Error                 = Class.new(StandardError)
  UnknownOperationError = Class.new(Error)
  OperationTypeError    = Class.new(Error)
  FunctionTypeError     = Class.new(Error)
  ListTypeError         = Class.new(Error)

  class Scope
    attr_accessor :names

    def initialize(names = {})
      @names = names
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

    def arity
      params.size
    end

    def dup
      self.class.new(params.dup, expression.dup)
    end
  end

  def initialize(parser)
    @parser = parser
    @call_stack = [Scope.new]
    @history = []
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
    type_check!(tree, Operation, OperationTypeError)

    case tree.operation
    when :close then exit(0)
    when :history then history
    when :clear then clear
    when :save then save
    when :load then load
    when :evaluate then evaluate(*tree.arguments)
    when :assign then assign(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :number then number(*tree.arguments)
    when :negate then negate(*tree.arguments)
    when :function then function(*tree.arguments)
    when :list then list(*tree.arguments)
    when :compose then compose(*tree.arguments)

    when :+ then self.+(*tree.arguments)
    when :- then self.-(*tree.arguments)
    when :* then self.*(*tree.arguments)
    when :/ then self./(*tree.arguments)
    when :% then self.%(*tree.arguments)
    when :^ then self.^(*tree.arguments)

    when :lt then lt(*tree.arguments)
    when :gt then gt(*tree.arguments)
    when :eq then eq(*tree.arguments)
    when :neq then neq(*tree.arguments)
    when :lte then lte(*tree.arguments)
    when :gte then gte(*tree.arguments)
    when :~ then self.~(*tree.arguments)

    else
      raise UnknownOperationError, tree.operation
    end
  rescue Error => e
    puts "error: #{e.class} - #{e.message}"
  rescue StandardError => e
    puts "oops #{e.message}"
  end

  def parse(buffer)
    parse_tree = @parser.parse(buffer)
    @history.push(buffer)

    parse_tree
  rescue StandardError => e
    # handle parsing errors
  end

  def history
    @history.pop # don't record the "history" statement
    @history.join("\n")
  end

  def clear
    @history.clear
  end

  def save
    @history.pop # don't record the "save" statement
    File.write("save.txt", @history.join("\n"))
    "saved"
  end

  def load
    @history.pop # don't record the "load" statement
    File.open("save.txt", "r").each_line do |line|
      tree = parse(line)
      puts tree
      evaluate(tree)
    end
    "loaded"
  end

  def +(x, y)
    evaluate(x) + evaluate(y)
  end

  def -(x, y)
    evaluate(x) - evaluate(y)
  end

  def *(x, y)
    evaluate(x) * evaluate(y)
  end

  def /(x, y)
    evaluate(x) / evaluate(y)
  end

  def %(x, y)
    evaluate(x) % evaluate(y)
  end

  def ^(x, y)
    evaluate(x) ** evaluate(y)
  end

  def lt(exp1, exp2)
    evaluate(exp1) < evaluate(exp2)
  end

  def gt(exp1, exp2)
    evaluate(exp1) > evaluate(exp2)
  end

  def eq(exp1, exp2)
    evaluate(exp1) == evaluate(exp2)
  end

  def neq(exp1, exp2)
    evaluate(exp1) != evaluate(exp2)
  end

  def lte(exp1, exp2)
    evaluate(exp1) <= evaluate(exp2)
  end

  def gte(exp1, exp2)
    evaluate(exp1) >= evaluate(exp2)
  end

  def ~(exp)
    !evaluate(exp)
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
    current_scope.names[operation.argument]
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
        if param.chars.first == 'ƒ'
          function_name = param[1..]
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
    yield.tap do
      pop_stack
    end
  end

  def list(array)
    Operation.new(:list, array)
  end

  def compose(expression, function_names)
    list = evaluate(expression)
    type_check!(list, Operation, OperationTypeError)

    return list if function_names.empty?

    func = function_names.shift

    expression =
      case func
      when 'first' then first(list)
      when 'rest' then rest(list)
      when 'last' then last(list)
      when 'max' then max(list)
      when 'min' then min(list)
      when 'sort' then sort(list)
      when 'sample' then sample(list)
      when 'shuffle' then shuffle(list)
      else compose_function(list, func)
      end

    compose(expression, function_names)
  end

  def compose_function(list, name)
    return compose_branch(list, name) if name.is_a?(Operation) && name.branch?

    function = current_scope.names[name]
    type_check!(function, Function, FunctionTypeError)

    result = list.map { |value| Operation.new(:number, evaluate_function(function, Array(value))) }

    Operation.new(:list, result)
  end

  def compose_branch(list, branch)
    control = current_scope.names[branch.arguments[0]]
    truthy_function = current_scope.names[branch.arguments[1]]
    falsey_function = current_scope.names[branch.arguments[2]]

    result = list.map do |value|
      if evaluate_function(control, Array(value))
        evaluate_function(truthy_function, Array(value))
      else
        evaluate_function(falsey_function, Array(value))
      end
    end

    Operation.new(:list, result)
  end

  def type_check!(value, type, error)
    raise error, value.inspect unless value.is_a?(type)
  end

  def first(list)
    Operation.new(:list, Array(list.argument.first))
  end

  def rest(list)
    Operation.new(:list, list.argument[1..])
  end

  def last(list)
    Operation.new(:list, Array(list.argument.last))
  end

  def max(list)
    sorted = list.argument.sort { |a, b| a.argument <=> b.argument }
    Operation.new(:list, Array(sorted.last))
  end

  def min(list)
    sorted = list.argument.sort { |a, b| a.argument <=> b.argument }
    Operation.new(:list, Array(sorted.first))
  end

  def sort(list)
    sorted = list.argument.sort { |a, b| a.argument <=> b.argument }
    Operation.new(:list, sorted)
  end

  def sample(list)
    Operation.new(:list, Array(list.argument.sample))
  end

  def shuffle(list)
    Operation.new(:list, list.argument.shuffle)
  end
end
