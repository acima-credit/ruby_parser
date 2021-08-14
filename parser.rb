# frozen_string_literal: true
class Action
  attr_accessor :action, :targets

  def initialize(action, targets)
    @action = action
    @targets = targets
  end
end

class Parser < Rly::Yacc
  rule 'expression : LOOK'\
  do |expression, _look|
    expression.value = Action.new(:look_around)
  end

  rule 'expression : LOOK NAME'\
  do |expression, _look, name|
    expression.value = Action.new(:look, name.value)
  end
end
