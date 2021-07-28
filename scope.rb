# A storage object for a scope (or stack frame)
class Scope
  def initialize
    # TODO: write a copy constructor for when we create new scopes from old scopes...
    @names = {}
  end

  def [](key)
    # TODO: Add KeyError for looking up something
    @names[key]
  end

  def []=(key, value)
    @names[key] = value
  end
end
