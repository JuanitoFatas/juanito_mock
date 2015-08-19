require "juanito_mock/version"

module JuanitoMock
  class StubTarget
    def initialize(obj)
      @obj = obj
    end

    def to(definition)
      @obj.define_singleton_method definition.message do
        definition.return_value
      end
    end
  end

  class ExpectationDefinition
    attr_reader :message, :return_value

    def initialize(message)
      @message = message
    end

    def and_return(return_value)
      @return_value = return_value
      self
    end
  end

  module TestExtensions
    def allow(obj)
      StubTarget.new(obj)
    end

    def receive(message)
      ExpectationDefinition.new(message)
    end
  end

  def self.reset
  end
end

class Minitest::Test
  include JuanitoMock::TestExtensions
end
