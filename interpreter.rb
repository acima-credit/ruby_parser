require_relative 'room'
require_relative 'item'

class Interpreter
  def initialize
    @inventory = {}
    @history = []

    map = Room.load_map

    @current_room = map.rooms["entrance"]
  end

  def evaluate(tree)
    @history.push(tree)

    case tree.action
    when :inventory then inventory
    when :history then history
    when :look then look(*tree.targets)
    when :open then open(*tree.targets)
    when :close then close(*tree.targets)
    when :look_around then look_around
    when :get then get(*tree.targets)
    when :drop then drop(*tree.targets)
    when :invoke then invoke(*tree.targets)
    when :go then go(*tree.targets)
    when :save then save
    else
      "Interpreter error: Cannot execute action '#{tree.action}'"
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
    puts e.backtrace
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
    target = @current_room.exits[name]
    exit(0) if target == 'exit'

    if target
      if target.is_a? Door
        if target.closed?
          "Sorry, the #{target.name} is closed."
        else
          # target is an open door; jump to its destination
          target = target.destination

          # Duplication is better than a bad abstraction, I need a nonbad abstraction here
          @current_room = target
          "You go #{name}. You are #{@current_room.here}."
        end
      else
        # Duplication is better than a bad abstraction, I need a nonbad abstraction here
        @current_room = target
        "You go #{name}. You are #{@current_room.here}."
      end
    else
      "You can't go that way."
    end
  end

  def open(names)
    name = names.last
    full_name = names.join(' ')

    # TODO: open things besides doors, e.g. envelope, chest, trapdoor
    # TODO: disambiguate objects, e.g. open iron door, open blue box
    if name == "door"
      doors = if names.size == 1
                @current_room.doors
              else
                @current_room.doors.select {|name, door| door.match?(names.first)}
              end

      case doors.size
      when 0
        "I see no door in this room."
      when 1
        door = doors.values.first

        if door.locked?
          "The #{door.name} is locked."
        elsif door.open?
          "The #{door.name} is already open."
        else
          door.open!
          "You open the #{door.name}."
        end
      else
        door_names = doors.map {|name, door| "the #{door.name}"}
        door_names = door_names[0..-2].join(', ') + " or " + door_names[-1]

        "Which door did you mean, #{door_names}?"
      end
    else
      "Sorry, I don't know how to open a #{name}."
    end
  end

  def close(names)
    # TODO: THIS IS A STRAIGHT RIP OF def open! Refactor THAT, then fix THIS.
    name = names.last
    full_name = names.join(' ')

    # TODO: close things besides doors, e.g. envelope, chest, trapdoor
    # TODO: disambiguate objects, e.g. close iron door, close blue box
    if name == "door"
      doors = if names.size == 1
                @current_room.doors
              else
                @current_room.doors.select {|name, door| door.match?(names.first)}
              end

      case doors.size
      when 0
        "I see no door in this room."
      when 1
        door = doors.values.first

        if door.closed?
          "The #{door.name} is already closed."
        else
          door.close!
          "You close the #{door.name}."
        end
      else
        door_names = doors.map {|name, door| "the #{door.name}"}
        door_names = door_names[0..-2].join(', ') + " or " + door_names[-1]

        "Which door did you mean, #{door_names}?"
      end
    else
      "Sorry, I don't know how to close a #{name}."
    end
  end

  def save
    File.open("save.yaml", "w") do |file|
      @history.find_all(&:targeted?).each { |action| file.write(action.to_yaml) }
    end
  end
end
