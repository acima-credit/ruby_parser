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
    when :evaluate then evaluate(*tree.arguments)
    when :close then close_toolbox
    when :add then add(*tree.arguments)
    when :subtract then subtract(*tree.arguments)
    when :multiply then multiply(*tree.arguments)
    when :divide then divide(*tree.arguments)
    when :raise then raise(*tree.arguments)
    when :number then number(*tree.arguments)
    when :lookup then lookup(*tree.arguments)
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
    name
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

  def raise(a, b)
    log "#raise #{a}, #{b}"
    evaluate(a) ** evaluate(b)
  end
end
