# frozen_string_literal: true

class Action
  attr_accessor :action, :targets

  def initialize(action, *targets)
    @action = action
    @targets = targets
  end

  def to_s
    if targets.empty?
      "<#{action}>"
    else
      "(#{action}: #{targets.join(', ')})"
    end
  end
end

class Parser < Rly::Yacc
  rule 'statement : HISTORY' do |statement, _history|
    statement.value = Action.new(:history)
  end

  rule 'statement : SAVE' do |statement, _save|
    statement.value = Action.new(:save)
  end

  rule 'statement : LOOK' do |statement, _look|
    statement.value = Action.new(:look_around)
  end

  rule 'statement : LOOK NAME' do |statement, _look, name|
    statement.value = Action.new(:look, name.value)
  end

  rule 'statement : OPEN NAME' do |statement, _open, name|
    statement.value = Action.new(:open, name.value)
  end

  rule 'statement : CLOSE NAME' do |statement, _close, name|
    statement.value = Action.new(:close, name.value)
  end

  rule 'statement : GO NAME' do |statement, _go, name|
    statement.value = Action.new(:go, name.value)
  end

  rule 'statement : INVENTORY' do |statement, _inv|
    statement.value = Action.new(:inventory)
  end

  rule 'statement : INVOKE NUMBER' do |statement, _invoke, number|
    statement.value = Action.new(:invoke, number.value)
  end
end
