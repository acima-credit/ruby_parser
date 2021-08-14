# frozen_string_literal: true
class Action
  attr_accessor :action, :targets

  def initialize(action, targets)
    @action = action
    @targets = targets
  end
end

class Parser < Rly::Yacc
  rule 'statement : LOOK'\
  do |statement, _look|
    statement.value = Action.new(:look_around)
  end
end
