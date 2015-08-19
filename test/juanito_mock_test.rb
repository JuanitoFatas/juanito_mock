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
end
