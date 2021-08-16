class Room
  attr_accessor :description, :items, :exits

  def initialize(description: "", items: {}, exits: {})
    @description = description
    @items = items
    @exits = exits
  end

  def items_description
    return "There are no items here" if items.empty?

    "You see: " + items.keys.join(', ')
  end

  def exists_description
    "You don't see any obvious exits" if exits.empty?

    "You see exits in #{exits.keys.join(', ')} directions"
  end

  def set_exit(direction, room)
    exits[direction] = room
  end
end


class Interpreter
  def initialize
    @inventory = {}

    entrance = Room.new(
      description: "You are at the entrance to a colossal cave",
      exits: { exit: 'exit' }
    )
    cave = Room.new(
      description: "You are standing in a cave. You can barely make out the walls from the dim light of the opening",
      exits: { north: entrance }
    )
    entrance.set_exit(:south, cave)

    @current_room = entrance
  end

  def evaluate(tree)
    case tree.action
    when :look then look(*tree.targets)
    when :lookup then lookup(*tree.targes)
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
  end

  def look_around
    puts @current_room.description
    puts @current_room.items_description
    puts @current_room.exists_description
  end

  def look(name)
    return look_around unless name

    puts "you look at #{name}"
  end

  def lookup(name)
    exit(0) if @current_room.exits[name] == 'exit'

    if @current_room.exits[name]
      @current_room = @current_room.exits[name]
    end
  end
end
