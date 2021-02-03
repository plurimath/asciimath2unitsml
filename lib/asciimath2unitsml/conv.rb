require "asciimath"
require "nokogiri"
require "htmlentities"
require "yaml"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze
  UNITSML_NS = "http://unitsml.nist.gov/2005".freeze

  class Conv
    def initialize
      @prefixes = read_yaml("../unitsdb/prefixes.yaml")
      @quantities = YAML.load_file(File.join(File.join(File.dirname(__FILE__),
                                                       "../unitsdb/quantities.yaml")))
      @units = read_yaml("../unitsdb/units.yaml")
    end

    def read_yaml(path)
      yaml = YAML.load_file(File.join(File.join(File.dirname(__FILE__), path)))
      yaml.each_with_object({}) do |(k, v), m|
        m[v["symbol"]] = v
        m[v["symbol"]]["id"] = k
      end
    end

    def Asciimath2UnitsML(x)
      xml = Nokogiri::XML(asciimath2mathml(x))
      xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
        next unless %r{^unitsml\(.+\)$}.match(x.text)
        x.replace(unitsml(x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")))
      end
      xml.to_xml
    end

    def UnitsML2MathML(x)
      x
    end

    def asciimath2mathml(x)
      AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
        AsciiMath.parse(HTMLEntities.new.decode(x)).ast).to_s.
      gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
    end

    def unitsml(x)
      "<unitsml xmlns='#{UNITSML_NS}'>#{x}</unitsml>"
    end
  end
end
