require "./test_framework"

class Person
  def initialize(name)
    @name = name
  end

  def name
    the_name = @name
    @name += " "
    the_name
  end
end

class MyTest < TestFramework
  it "should match the name passed into the initializer" do
    name = "Steve"
    person = Person.new(name)
    assert(person.name == name)
  end

  it "should return the same name if called twice" do
    name = "Jason"
    person = Person.new(name)
    name_first_time = person.name
    name_second_time = person.name

    assert(name_first_time == name_second_time)
  end

  run
end