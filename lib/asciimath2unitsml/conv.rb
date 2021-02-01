require "asciimath"
require "nokogiri"
require "htmlentities"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze
  UNITSML_NS = "http://unitsml.nist.gov/2005".freeze

  def self.Asciimath2UnitsML(x)
    xml = Nokogiri::XML(asciimath2mathml(x))
    xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
      next unless %r{^unitsml\(.+\)$}.match(x.text)
      x.replace(unitsml(x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")))
    end
    xml.to_xml
  end

  def self.UnitsML2MathML(x)
    x
  end

  def self.asciimath2mathml(x)
    AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
      AsciiMath.parse(HTMLEntities.new.decode(x)).ast).to_s.
        gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
  end

  def self.unitsml(x)
    "<unitsml xmlns='#{UNITSML_NS}'>#{x}</unitsml>"
  end
end
