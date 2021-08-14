class Room
  attr_accessor :description, :items, :exits

  def initialize(description)
    @description = description
    @items = {}
    @exits = {}
  end

  def items_description
    return "There are no items here" if items.empty?

    "You see: " + items.keys.join(', ')
  end

  def exists_description
    "You don't see any obvious exits" if exits.empty?
  end
end

class Interpreter
  def initialize
    @inventory = {}
    @rooms = [Room.new("You are at the entrance to a vast maze")]
  end

  def current_room
    @rooms.last
  end

  def evaluate(tree)
    case tree.action
    when :look then look(*tree.targets)
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
  end

  def look_around
    puts current_room.description
    puts current_room.items_description
    puts current_room.exists_description
  end

  def look(name)
    return look_around unless name

    puts "you look at #{name}"
  end
end
