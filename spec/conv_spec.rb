require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts an AsciiMath string to MathML + UnitsML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    32 + 5 xx 7 "unitsml(kg^-2)" xx 9 "unitsml(g)" xx 1 "unitsml(kg*s^-2)" xx 812 "unitsml(m*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <unitsml xmlns='http://unitsml.nist.gov/2005'>kg^-2</unitsml>
         <mo>&#xD7;</mo>
         <mn>9</mn>
         <unitsml xmlns='http://unitsml.nist.gov/2005'>g</unitsml>
         <mo>&#xD7;</mo>
         <mn>1</mn>
         <unitsml xmlns='http://unitsml.nist.gov/2005'>kg*s^-2</unitsml>
         <mo>&#xD7;</mo>
         <mn>812</mn>
         <unitsml xmlns='http://unitsml.nist.gov/2005'>m*s^-2</unitsml>
</math>
    OUTPUT
  end

  it "raises error for illegal unit" do
    expect{xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))}.to raise_error(Rsec::SyntaxError)
    12 "unitsml(que?)"
    INPUT
  end

  it "converts MathML + UnitsML to pure MathML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().UnitsML2MathML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
        <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <unitsml xmlns='http://unitsml.nist.gov/2005'>g</unitsml>
</math>
    INPUT
        <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <unitsml xmlns='http://unitsml.nist.gov/2005'>g</unitsml>
</math>
    OUTPUT
  end
end
