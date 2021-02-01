require "asciimath"
require "nokogiri"
require "htmlentities"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze

  def self.conv(x)
    m = AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
      AsciiMath.parse(HTMLEntities.new.decode(x)).ast).to_s.
        gsub(/<math>/, "<math xmlns='http://www.w3.org/1998/Math/MathML'>")
  end
end
