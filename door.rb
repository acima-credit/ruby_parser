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
              :destination,
              :state

  LOCKED = "locked"
  CLOSED = "closed"
  OPEN   = "open"
  STATES = [OPEN, CLOSED, LOCKED]

  def initialize(name:, destination:, state:,
                 description_always:, description_closed:,
                 description_locked:, description_open:)
    raise ArgumentError.new("state must be one of #{STATES.join(',')}") unless STATES.include?(state)

    @name = name
    @destination = destination
    @state = state
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

  def locked?
    state == LOCKED
  end

  def unlocked?
    !locked?
  end

  def closed?
    locked? || state == CLOSED
  end

  def open?
    !closed?
  end

  def open!
    @state = OPEN
  end

  def close!
    @state = CLOSED
  end

  def lock!
    @state = LOCKED
  end
end
