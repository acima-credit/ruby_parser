# frozen_string_literal: true

class Action
  attr_accessor :action, :targets

  def initialize(action, *targets)
    @action = action
    @targets = targets
  end

  def targeted?
    !targets.empty?
  end

  def to_s
    if targets.empty?
      "<#{action}>"
    else
      "(#{action}: #{targets.join(', ')})"
    end
  end

  def to_yaml
<<-YAML
- action: #{action}
  targets: [#{targets.join(',')}]
YAML
  end
end

class Parser < Rly::Yacc
  rule 'statement : HISTORY' do |statement, _history|
    statement.value = Action.new(:history)
  end

  rule 'statement : SAVE' do |statement, _save|
    statement.value = Action.new(:save)
  end

  rule 'statement : LOOK NUMBER | LOOK NAME' do |statement, _look, name|
    statement.value = Action.new(:look, name.value)
  end

  rule 'statement : GET NUMBER | GET NAME' do |statement, _get, name|
    statement.value = Action.new(:get, name.value)
  end

  rule 'statement : DROP NUMBER | DROP NAME' do |statement, _drop, name|
    statement.value = Action.new(:drop, name.value)
  end

  rule 'statement : LOOK' do |statement, _look|
    statement.value = Action.new(:look_around)
  end

  rule 'statement : OPEN object' do |statement, _open, object|
    statement.value = Action.new(:open, object.value)
  end

  rule 'statement : CLOSE object' do |statement, _close, object|
    statement.value = Action.new(:close, object.value)
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

  rule 'object : NAME
               | NAME NAME' do |object, adjective, noun|
    object.value = Array(adjective.value) + Array(noun&.value)
  end
end
