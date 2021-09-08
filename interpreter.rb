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

  def push_scope(temporary_scope)
    copied_current_scope = current_scope

    temporary_scope.functions.merge! copied_current_scope.functions
    temporary_scope.values.merge! copied_current_scope.values

    @stack.push temporary_scope
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

    when :equivalent then equivalent(*tree.arguments)
    when :non_equivalent then non_equivalent(*tree.arguments)
    when :less_than then less_than(*tree.arguments)
    when :greater_than then greater_than(*tree.arguments)
    when :less_than_or_equal then less_than_or_equal(*tree.arguments)
    when :greater_than_or_equal then greater_than_or_equal(*tree.arguments)
    when :compare_and then compare_and(*tree.arguments)
    when :compare_or then compare_or(*tree.arguments)

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

  def arithmetic_type_check(x, y)
    x.operation == :number && y.operation == :number
  end

  def lookup(value)
    log "#lookup #{value}"
    if current_scope.values.has_key?(value)
      current_scope.values[value]
    else
      return "Cannot lookup undefined variable '#{value}'"
    end
  end

  def add(a, b)
    log "#add #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) + evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def subtract(a, b)
    log "#subtract #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) - evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def multiply(a, b)
    log "#multiply #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) * evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def divide(a, b)
    log "#divide #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) / evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def modulo(a, b)
    log "#modulo #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) % evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def power(a, b)
    log "#power #{a}, #{b}"
    if arithmetic_type_check(a, b)
      evaluate(a) ** evaluate(b)
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def negate(a)
    log "#negate #{a}"
    if arithmetic_type_check(a, 0)
      evaluate(a) * -1
    else
      log "TypeError: One or more parameters is not a number"
      #raise TypeError
    end
  end

  def assign(var_name, var_value)
    log "#assign variable #{var_name} to value #{var_value}"
    current_scope.values[var_name] = evaluate(var_value)
  end

  def declare(name, body)
    log "#declare function #{name} to the following definition: #{body}"
    current_scope.functions[name] = body # not evaluating until function call ('ring')
    log "This is current_scope.functions[name] #{current_scope.functions[name]}"
  end

  def declare_with_params(name, param_names, body) # need to handle "rogue" undefined params in the body
    log "\n\n#declare function name #{name} with param_names #{param_names} and function body #{body}"
    current_scope.functions[name] = { params: param_names, body: body } # not evaluating until function call ('ring')
    log "This is name:  #{name}"
    log "This is params:  #{param_names}"
    log "This is body:  #{body}"
    log "This is current_scope.functions[name] #{current_scope.functions[name]}\n\n"
  end # x with b,c,d,e ~ b + c + 5

  def ring(name)
    local_scope = Scope.new
    push_scope(local_scope)

    log "#ring function #{name}"
    if current_scope.functions.has_key? name
      result = evaluate(current_scope.functions[name])
      pop_scope
      return result
    else
      log "Cannot lookup undefined function '#{name}'"
      pop_scope
      return
    end
  end

  def ring_with_args(name, args)
    local_scope = Scope.new
    push_scope(local_scope)

    log "#ring function #{name} with args #{args}"
    if current_scope.functions.has_key? name
      binding.pry
      params = current_scope.functions[name]
      pop_scope
      return result
    else
      puts "Cannot lookup undefined function '#{name}'"
      pop_scope
      raise "Lookup error"
    end
  end

  # comparison functions
  def equivalent(a, b)
    evaluate(a) == evaluate(b)
  end

  def non_equivalent(a, b)
    evaluate(a) != evaluate(b)
  end

  def less_than(a, b)
    evaluate(a) < evaluate(b)
  end

  def greater_than(a, b)
    evaluate(a) > evaluate(b)
  end

  def less_than_or_equal(a, b)
    evaluate(a) <= evaluate(b)
  end

  def greater_than_or_equal(a, b)
    evaluate(a) >= evaluate(b)
  end

  def compare_and(a, b)
    evaluate(a) && evaluate(b) ? true : false
  end

  def compare_or(a, b)
    evaluate(a) || evaluate(b) ? true : false
  end
end


# From: /Users/jason.loutensock/practice/ruby_parser/interpreter.rb:210 Interpreter#ring_with_args:

#     204: def ring_with_args(name, args)
#     205:   local_scope = Scope.new
#     206:   push_scope(local_scope)
#     207: 
#     208:   log "#ring function #{name} with args #{args}"
#     209:   if current_scope.functions.has_key? name
#  => 210:     binding.pry
#     211:     params = current_scope.functions[name]
#     212:     pop_scope
#     213:     return result
#     214:   else
#     215:     puts "Cannot lookup undefined function '#{name}'"
#     216:     pop_scope
#     217:     raise "Lookup error"
#     218:   end
#     219: end

# [1] pry(#<Interpreter>)> current_scope.functions[name][:params]
# => ["a"]
# [2] pry(#<Interpreter>)> current_scope.functions[name][:body]
# => #<Operation:0x00007fe75e88f598
#  @arguments=[#<Operation:0x00007fe77f8b25b8 @arguments=["a"], @operation=:lookup>, #<Operation:0x00007fe77f8d25c0 @arguments=["8"], @operation=:number>],
#  @operation=:add>
# [3] pry(#<Interpreter>)> args
# => [#<Operation:0x00007fe77f8e1ae8 @arguments=["2"], @operation=:number>]
# [4] pry(#<Interpreter>)> args.size
# => 1
# [5] pry(#<Interpreter>)> current_scope.functions[name][:params].size
# => 1
# [6] pry(#<Interpreter>)> args.size.times do |index|
# [6] pry(#<Interpreter>)*   "puts args[#{index}] is #{args[index]}"
# [6] pry(#<Interpreter>)* end  
# => 1
# [7] pry(#<Interpreter>)> args.size.times do |index|
# [7] pry(#<Interpreter>)*   "pus arg"s[#{index}] is #{args[index]}"  
# SyntaxError: unexpected tIDENTIFIER, expecting end
#   "pus arg"s[#{index}] is #{args[index]}"
#            ^
# [7] pry(#<Interpreter>)> args.size.times do |index|
# [7] pry(#<Interpreter>)*   puts "args[#{index}] is #{args[index]}"
# [7] pry(#<Interpreter>)* end  
# args[0] is (number: 2)
# => 1
# [8] pry(#<Interpreter>)> 
# [8] pry(#<Interpreter>)> ray1 = ["a", "b", "c"]
# => ["a", "b", "c"]
# [9] pry(#<Interpreter>)> ray2 = [1, 2, 3]
# => [1, 2, 3]
# [10] pry(#<Interpreter>)> ray1.zip(ray2)
# => [["a", 1], ["b", 2], ["c", 3]]
# [11] pry(#<Interpreter>)> ray1.zip(ray2) do |name, value|
# [11] pry(#<Interpreter>)*   puts "Let's assign #{name} = #{value} in the current scope"
# [11] pry(#<Interpreter>)* end  
# Let's assign a = 1 in the current scope
# Let's assign b = 2 in the current scope
# Let's assign c = 3 in the current scope