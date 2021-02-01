require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts a string" do
    expect(xmlpp(Asciimath2UnitsML.conv(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    32 + 5 xx 7 "unitsml(g)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <UnitsML>g</UnitsML>
</math>
    OUTPUT
  end
end
