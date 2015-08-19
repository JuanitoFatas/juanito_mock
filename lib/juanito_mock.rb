require "juanito_mock/version"

module JuanitoMock
  class StubTarget
    def initialize(obj)
      @obj = obj
    end

    def to(definition)
      Stubber.for_object(@obj).stub(definition)
    end
  end

  class Stubber
    def self.stubbers
      @stubbers ||= {}
    end

    def self.for_object(obj)
      stubbers[obj.__id__] ||= Stubber.new(obj)
    end

    def self.reset
      stubbers.each_value(&:reset)
      stubbers.clear
    end

    def initialize(obj)
      @obj = obj
      @definitions = []
    end

    def stub(definition)
      @definitions << definition

      @obj.define_singleton_method definition.message do
        definition.return_value
      end
    end

    def reset
      @definitions.each do |definition|
        @obj.singleton_class.class_eval do
          remove_method(definition.message) if method_defined?(definition.message)
        end
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
    Stubber.reset
  end
end

class Minitest::Test
  include JuanitoMock::TestExtensions
end
