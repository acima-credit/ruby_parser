# frozen_string_literal: true

require 'colorize'

# A base class to use in your code to test things
class TestFramework
  class << self
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
        log("*".green)
      else
        log("F".red)
      end
    end

    def log(message)
      print(message)
    end

    def run
      @tests.to_a.shuffle.each do |name, expectation|
        print("#{name}: ")
        log(" #{expectation.call}")
        puts
      end
    end
  end
end
