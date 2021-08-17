# door.rb

# How do doors work?
#

# Doors are one-way portals between rooms, working exactly like exits. In fact,
# a room can have an exit OR a door (but not both) in any given direction. Door
# descriptions get included by the room when looking at the room. Doors can be
# open or closed, locked or unlocked, and if they are open their direction will
# be included in the list of exits.

# As a quick hack, doors are shimmed into exits directly, and the room and
# interpreter know to test an exit for, um, "door-ness". If you look, you will
# not see a door's exit if it is closed, and if you try to go in the direction
# of a door that is closed, you'll get a failure message specific to doors (but
# that still means "you can't go that way").

class Door
  attr_reader :name,
              :description_always,
              :description_closed,
              :description_locked,
              :description_open,
              :destination


  attr_accessor :closed, :locked

  def initialize(name:, destination:, closed:, locked:,
                 description_always:, description_closed:,
                 description_locked:, description_open:)
    @name = name
    @destination = destination
    @closed = closed
    @locked = locked
    @description_always = description_always
    @description_closed = description_closed
    @description_locked = description_locked
    @description_open = description_open
  end

  def description
    text = description_always + " "
    text += if locked?
              description_locked
            elsif closed?
              description_closed
            else
              description_open
            end
  end

  def set_exit(room)
    @destination = room
  end


  # Blech. It's a 2x2 state machine. I kinda hate the booleans here, if I'm
  # writing a new door I'm as like as not to try to say open: true instead of
  # closed: false. Bleh. It's sleepy and I'm late, would enums be any better?
  def locked?
    !!locked == true
  end

  def unlocked?
    !locked?
  end

  def closed?
    !!closed == true
  end

  def open?
    !closed?
  end

  # See above comment about booleans vs. enums. I wrote this because I couldn't
  # remember if I should set door.open to true or door.closed to false.
  def open!
    self.closed = false
  end

  def close!
    self.closed = true
  end
end
