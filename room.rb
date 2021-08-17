class Room
  attr_accessor :description, :items, :exits

  def initialize(description:, items: {}, exits: {})
    @description = description || "You are in a maze of twisty little passages, all alike."
    @items = items
    @exits = exits
  end

  def items_description
    return "There are no items here" if items.empty?

    "You see: #{items.values.map { |i| i.to_s.colorize(:light_blue) }.join(', ')}"
  end

  def exists_description
    "You don't see any obvious exits" if exits.empty?

    "Exits are: #{exits.keys.map { |k| k.to_s.colorize(:yellow) }.join(', ')}"
  end

  def set_exit(direction, room)
    exits[direction] = room
  end

  def to_s
    description
  end
end
