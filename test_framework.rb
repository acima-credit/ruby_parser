# frozen_string_literal: true

# A base class to use in your code to test things
class TestFramework
  class << self
    # Does not work yet!
    # Needs a scope stack
    def describe(name, &block)
      @tests ||= {}
      @tests[name] = block
    end

    # it "should do something" { expect() }
    def it(*args, &block)
      @tests ||= {}

      key = if args[0].is_a?(String)
        args[0]
      else
        "test"
      end

      @tests[key] = block
    end

    # assert(1 == 1)
    def assert(value)
      if value
        log("\tIt worked")
      else
        log("\tIt didn't work")
      end
    end

    def log(message)
      puts(message)
    end

    def run
      @tests.to_a.shuffle.each do |name, expectation|
        log(name)
        log("\t#{expectation.call}")
      end
    end
  end
end
