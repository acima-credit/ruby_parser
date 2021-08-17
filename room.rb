require 'yaml' # yaml/store, perhaps?

class Room
  attr_accessor :here, :description, :items, :exits

  def initialize(here:, description:, items: {}, exits: {})
    @here = here
    @description = description || "You are in a maze of twisty little passages, all alike."
    @items = items
    @exits = exits
  end

  def self.load_rooms
    rooms = {}
    rooms_data = YAML::load_file("./adventure_rooms.yml")
    # hydrate the objects
    rooms_data.each do |name, room_data|
      rooms[name] = Room.new(
        here: room_data["here"],
        description: room_data["description"]
      )
    end

    # haxxor in an exit room
    rooms["exit"] = "exit"

    # now stitch up the exit names to real room objects
    # could also do this in the go command, but this works too.
    rooms_data.each do |name, room_data|
      room_data["exits"].each do |direction, destination|
        if rooms[destination]
          rooms[name].set_exit(direction, rooms[destination])
        else
          # Warn us on load if we have a tyop in adventure_rooms.yml
          puts "WARNING:".bold.white.on_red + " rooms[#{name.inspect}].set_exit(#{direction.inspect}, #{destination.inspect}): destination room does not exist."
        end
      end
    end
    puts "#{rooms.size-1} ROOMS LOADED!".bold.white.on_green
    rooms
  end

  def items_description
    return "There are no items here." if items.empty?

    "You see: #{items.values.map { |i| i.to_s.colorize(:light_blue) }.join(', ')}."
  end

  def exists_description
    "You don't see any obvious exits." if exits.empty?

    "Exits are: #{exits.keys.map { |k| k.to_s.colorize(:yellow) }.join(', ')}"
  end

  def set_exit(direction, room)
    exits[direction] = room
  end

  def to_s
    description
  end
end
