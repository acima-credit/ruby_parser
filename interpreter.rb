class Room
  attr_accessor :items

  def initialize
    @items = {}
  end
end

class Interpreter
  def initialize
    @inventory = {}
    @rooms = [Room.new]
  end

  def current_room
  end

  def evaluate(tree)
    case tree.action
    when :look_around then look_around
    when :look then look(*tree.targets)
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
  end

  def look_around
    puts "you look around"
  end

  def look(name)

  end
end
