require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts a string" do
    expect(Asciimath2UnitsML.conv("abc")).to be_equivalent_to <<~OUTPUT
           abc
    OUTPUT
  end
end
