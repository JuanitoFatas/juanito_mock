require "juanito_mock/version"

module JuanitoMock
  ExpectationNotSatisfied = Class.new(StandardError)

  class StubTarget
    def initialize(obj)
      @obj = obj
    end

    def to(definition)
      Stubber.for_object(@obj).stub(definition)
    end
  end

  class ExpectationTarget < StubTarget
    def to(definition)
      super
      JuanitoMock.expectations << definition
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
      @preserved_methods = []
    end

    def stub(definition)
      @definitions << definition

      if @obj.singleton_class.method_defined?(definition.message)
        @preserved_methods <<
          @obj.singleton_class.instance_method(definition.message)
      end

      @obj.define_singleton_method definition.message do
        definition.call
      end
    end

    def reset
      @definitions.each do |definition|
        @obj.singleton_class.class_eval do
          remove_method(definition.message) if method_defined?(definition.message)
        end
      end

      @preserved_methods.reverse_each do |method|
        @obj.define_singleton_method(method.name, method)
      end
    end
  end

  class ExpectationDefinition
    attr_reader :message, :return_value

    def initialize(message)
      @message = message
      @invocation_count = 0
    end

    def and_return(return_value)
      @return_value = return_value
      self
    end

    def call
      @invocation_count += 1
      @return_value
    end

    def verify
      if @invocation_count != 1
        raise ExpectationNotSatisfied
      end
    end
  end

  module TestExtensions
    def allow(obj)
      StubTarget.new(obj)
    end

    def assume(obj)
      ExpectationTarget.new(obj)
    end

    def receive(message)
      ExpectationDefinition.new(message)
    end
  end

  def self.reset
    expectations.each(&:verify)
  ensure
    expectations.clear
    Stubber.reset
  end

  def self.expectations
    @expectations ||= []
  end
end

class Minitest::Test
  include JuanitoMock::TestExtensions
end
