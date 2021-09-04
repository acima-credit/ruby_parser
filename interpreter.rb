class Interpreter

  class Scope
    attr_reader :values, :functions

    def initialize
      @values = {}
      @functions = {}
    end
  end

  def initialize
    @stack = [Scope.new]
  end

  def current_scope
    @stack.last
  end

  def pop_scope
    @stack.pop
  end

  def self.log(msg)
    $stdout.puts "Interpreter: #{msg}".black.on_light_magenta
    $stdout.flush
  end

  def log(msg)
    self.class.log(msg)
  end

  def evaluate(tree)
    case tree.operation
    when :assign then assign(*tree.arguments)
    when :evaluate then evaluate(*tree.arguments)
    when :close then close_toolbox
    when :negate then negate(*tree.arguments)
    when :add then add(*tree.arguments)
    when :subtract then subtract(*tree.arguments)
    when :multiply then multiply(*tree.arguments)
    when :divide then divide(*tree.arguments)
    when :power then power(*tree.arguments)
    when :modulo then modulo(*tree.arguments)
    when :number then number(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
    when :declare then declare(*tree.arguments)
    when :declare_with_params then declare_with_params(*tree.arguments)
    when :ring then ring(*tree.arguments)
    when :ring_with_args then ring_with_args(*tree.arguments)
    else
      puts "I don't know how to handle operation '#{tree.operation}'!"
    end
  end

  def close_toolbox
    log "Closing toolbox."
    exit
  end

  def number(number)
    log "#number #{number}"
    number.to_f
  end

  def lookup(value)
    log "#lookup #{value}"
    if current_scope.values.has_key? value
      current_scope.values[value]
    else
      return "Cannot lookup undefined variable '#{value}'"
    end
  end

  def add(a, b)
    log "#add #{a}, #{b}"
    evaluate(a) + evaluate(b)
  end

  def subtract(a, b)
    log "#subtract #{a}, #{b}"
    evaluate(a) - evaluate(b)
  end

  def multiply(a, b)
    log "#multiply #{a}, #{b}"
    evaluate(a) * evaluate(b)
  end

  def divide(a, b)
    log "#divide #{a}, #{b}"
    evaluate(a) / evaluate(b)
  end

  def modulo(a, b)
    log "#modulo #{a}, #{b}"
    evaluate(a) % evaluate(b)
  end

  def power(a, b)
    log "#power #{a}, #{b}"
    evaluate(a) ** evaluate(b)
  end

  def negate(a)
    log "#negate #{a}"
    evaluate(a) * -1
  end

  def assign(var_name, var_value)
    log "#assign variable #{var_name} to value #{var_value}"
    current_scope.values[var_name] = evaluate(var_value)
  end

  def declare(name, body)
    if body.to_s.scan("@operation=:lookup") # ugly, but it works. how can we do this better?
      log "Undefined arguments in function body: #{body}"
      return
    end
    log "#declare function #{name} to the following definition: #{body}"
    current_scope.functions[name] = body # not evaluating until function call ('ring')
    log "This is current_scope.functions[name] #{current_scope.functions[name]}"
  end

  def declare_with_params(name, params, body) # need to handle "rogue" undefined params in the body
    log "\n\n#declare function name #{name} with params #{params} and function body #{body}"
    current_scope.functions[name] = { params: params, body: body } # not evaluating until function call ('ring')
    log "This is name:  #{name}"
    log "This is params:  #{params}"
    log "This is body:  #{body}"
    log "This is current_scope.functions[name] #{current_scope.functions[name]}\n\n"
  end # x with b,c,d,e ~ b + c + 5

  def ring(name)
    log "#ring function #{name}"
    if current_scope.functions.has_key? name
      evaluate(current_scope.functions[name])
    else
      return "Cannot lookup undefined function '#{name}'"
    end
  end

  def ring_with_args(name, args)
    log "#ring function #{name} with args #{args}"
    if current_scope.functions.has_key? name
      evaluate(current_scope.functions[name])
    else
      puts "Cannot lookup undefined function '#{name}'"
      raise "Lookup error"
    end
  end
end
