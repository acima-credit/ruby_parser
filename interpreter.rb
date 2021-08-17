require_relative 'room'
require_relative 'item'

class Interpreter
  def initialize
    @inventory = {}
    @history = []

    rooms = Room.load_rooms

    @current_room = rooms["entrance"]
  end

  def evaluate(tree)
    @history.push(tree)

    case tree.action
    when :inventory then inventory
    when :history then history
    when :look then look(*tree.targets)
    when :look_around then look_around
    when :get then get(*tree.targets)
    when :drop then drop(*tree.targets)
    when :invoke then invoke(*tree.targets)
    when :go then go(*tree.targets)
    when :save then save
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
  end

  def inventory
    return "You aren't carrying anything." if @inventory.empty?

    "You are carrying: #{@inventory.values.join(', ')}"
  end

  def history
    @history.join("\n")
  end

  def look_around
    puts @current_room.description.on_black
    puts @current_room.items_description.on_black
    puts @current_room.exists_description.on_black
  end

  def look(name)
    if @current_room.items[name]
      @current_room.items[name].description
    else
      "There isn't a #{name} here to look at."
    end
  end

  def invoke(number)
    @current_room.items[number] = Item.new(
      summary: number,
      description: "It is an unremarkable #{number}",
      type: :number
    )
  end

  def get(name)
    if @current_room.items[name]
      @inventory[name] = @current_room.items.delete(name)
      "You get the #{name} and add it to your inventory."
    else
      "There isn't a #{name} here to get."
    end
  end

  def drop(name)
    if @inventory[name]
      @current_room.items[name] = @inventory.delete(name)
      "You drop the #{name} here."
    else
      "You don't have a #{name} to drop"
    end
  end

  def go(name)
    exit(0) if @current_room.exits[name] == 'exit'

    if @current_room.exits[name]
      @current_room = @current_room.exits[name]
      "You go #{name}. You are #{@current_room.here}."
    else
      "You can't go that way."
    end
  end

  def save
    File.open("save.yaml", "w") do |file|
      @history.find_all(&:targeted?).each { |action| file.write(action.to_yaml) }
    end
  end
end
