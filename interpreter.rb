require_relative 'room'
require 'yaml'

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
    when :lookup then lookup(*tree.targets)
    when :invoke then invoke(*tree.targets)
    when :go then go(*tree.targets)
    when :save then save
    end
  rescue StandardError => e
    puts "Oops: #{e.class} #{e.message}"
  end

  def inventory
    return "You aren't carrying anything." if @inventory.empty?

    puts "You are carrying: #{@inventory.values.join(', ')}"
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
    return look_around unless name

    puts "You look at #{name}."
  end

  def lookup(name)
    exit(0) if @current_room.exits[name] == 'exit'

    if @current_room.exits[name]
      @current_room = @current_room.exits[name]
    end
  end

  def invoke(number)
    @current_room.items[number] = "A number #{number}"
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

  def open(name)
    # TODO: open things besides doors, e.g. envelope, chest, trapdoor
    # TODO: disambiguate objects, e.g. open iron door, open blue box
    if name == "door"
      doors = @current_room.doors

      case doors.size
      when 0
        "I see no door in this room."
      when 1
        door = doors.values.first

        if door.locked?
          "The #{door.name} is locked."
        else
          door.open!
          "You open the #{door.name}."
        end
      else
        # TODO: handle door disambiguation here
        "ERROR:".bold.white.on_red +
          " Object disambiguation needed -- multiple doors in room: " +
          doors.values.map(&:name).inspect
      end
    end
  end

  def close(name)
    # TODO: THIS IS A STRAIGHT RIP OF def open! Refactor THAT, then fix THIS.
    if name == "door"
      doors = @current_room.doors

      case doors.size
      when 0
        "I see no door in this room."
      when 1
        door = doors.values.first

        if door.locked? # yes a door can be locked open
          "The #{door.name} is locked."
        else
          door.close!
          "You close the #{door.name}."
        end
      else
        # TODO: handle door disambiguation here
        "ERROR:".bold.white.on_red +
          " Object disambiguation needed -- multiple doors in room: " +
          doors.values.map(&:name).inspect
      end
    end
  end

  def save
    # output @history to file
  end
end
