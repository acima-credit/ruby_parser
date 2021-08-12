class Interpreter
  def initialize
    @names = {}
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
    when :negate then negate(*tree.arguments)
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

  def lookup(name)
    log "#lookup #{name}"
    if @names.has_key? name
      @names[name]
    else
      puts "Cannot lookup undefined variable '#{name}'"
      raise "Lookup error"
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
    @names[var_name] = evaluate(var_value)
  end
end
