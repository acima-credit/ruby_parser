require 'yaml' # yaml/store, perhaps? Room is fine without it but UGH, doors.
require_relative 'door'

# TODO: Move me into a map.rb file and have Map.load_map load the rooms and doors.
Map = Struct.new :rooms, :doors

class Room
  attr_accessor :here, :description, :items, :exits

  def initialize(here:, description:, items: {}, exits: {})
    @here = here
    @description = description || "You are in a maze of twisty little passages, all alike."
    @items = items
    @exits = exits
  end

  def self.load_map
    map = Map.new({},{})

    rooms_data = YAML::load_file("./adventure_rooms.yml")
    doors_data = YAML::load_file("./adventure_doors.yml")

    # hydrate the objects
    rooms_data.each do |name, room_data|
      map.rooms[name] = Room.new(
        here: room_data["here"],
        description: room_data["description"]
      )
    end

    doors_data.each do |name, door_data|
      map.doors[name] = Door.new(
        name: door_data["name"],
        state: door_data["state"],
        adjectives: door_data["adjectives"],
        description_always: door_data["description_always"],
        description_closed: door_data["description_closed"],
        description_open: door_data["description_open"],
        description_locked: door_data["description_locked"],
        destination: door_data["destination"],
      )
    end

    # haxxor in an exit room
    map.rooms["exit"] = "exit"

    # now stitch up the exit names to real room objects
    # could also do this in the go command, but this works too.
    rooms_data.each do |name, room_data|
      room_data["exits"].each do |direction, destination|
        target = map.rooms[destination] || map.doors[destination]
        if target
          map.rooms[name].set_exit(direction, target)
        else
          # Warn us on load if we have a tyop in adventure_rooms.yml
          puts "WARNING:".bold.white.on_red + " map.rooms[#{name.inspect}].set_exit(#{direction.inspect}, #{destination.inspect}): destination room does not exist."
        end
      end
    end

    # and stitch up door exits, too
    map.doors.each do |name, door|
      room = map.rooms[door.destination]
      if room
        door.set_exit(room)
      else
        # Warn us on load if we have a tyop in adventure_doors.yml
        puts "WARNING:".bold.white.on_red + " map.doors[#{name.inspect}].set_exit(#{room.inspect}): destination room does not exist."
      end
    end

    # Emit success message
    puts "#{map.rooms.size-1} ROOMS AND #{map.doors.size} DOORS LOADED!".bold.white.on_green
    map
  end

  def description
    @description + " " + doors.values.map(&:description).join(". ") + "."
  end

  def items_description
    return "There are no items here." if items.empty?

    "You see: #{items.keys.map { |i| i.to_s.colorize(:light_blue) }.join(', ')}."
  end

  def exists_description
    "You don't see any obvious exits." if open_exits.empty?

    "Exits are: #{open_exits.keys.map { |k| k.to_s.colorize(:yellow) }.join(', ')}"
  end

  # An exit is open it if it is another room, or if it is an open door.
  def open_exits
    exits.select {|direction, target| !target.is_a?(Door) || target.open? }
  end

  def doors
    exits.select {|direction, target| target.is_a?(Door) }
  end

  def set_exit(direction, room)
    exits[direction] = room
  end

  def to_s
    description
  end
end
