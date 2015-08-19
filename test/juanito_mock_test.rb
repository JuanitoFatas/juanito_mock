require "test_helper"

describe JuanitoMock do
  it "allows an object to receive a message and returns a value" do
    warehouse = Object.new

    allow(warehouse).to receive(:full?).and_return(true)

    warehouse.full?.must_equal true
  end

  it "removes stubbed method after tests finished" do
    warehouse = Object.new

    allow(warehouse).to receive(:full?).and_return(true)

    JuanitoMock.reset

    assert_raises(NoMethodError) { warehouse.full? }
  end

  it "preserves methods that originally existed" do
    warehouse = Object.new
    def warehouse.full?; false; end # defining methods on Ruby singleton class

    allow(warehouse).to receive(:full?).and_return(true)

    JuanitoMock.reset

    warehouse.full?.must_equal false
  end

  it "expects that a message will be received" do
    warehouse = Object.new

    assume(warehouse).to receive(:empty)

    # warehouse.empty not called!

    assert_raises(JuanitoMock::ExpectationNotSatisfied) do
      JuanitoMock.reset
    end
  end

  it "does not raise an error if expectations are satisfied" do
    warehouse = Object.new

    assume(warehouse).to receive(:empty)

    warehouse.empty

    JuanitoMock.reset # assert nothing raised!
  end

  it "allows object to receive messages with arguments" do
    warehouse = Object.new

    allow(warehouse).to receive(:include?).with(1234).and_return(true)
    allow(warehouse).to receive(:include?).with(9876).and_return(false)

    warehouse.include?(1234).must_equal true
    warehouse.include?(9876).must_equal false
  end
end
