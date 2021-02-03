require "asciimath"
require "nokogiri"
require "htmlentities"
require "yaml"
require "rsec"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze
  UNITSML_NS = "http://unitsml.nist.gov/2005".freeze
 
  class Conv
    include Rsec::Helpers

    def initialize
      @prefixes = read_yaml("../unitsdb/prefixes.yaml")
      @quantities = YAML.load_file(File.join(File.join(File.dirname(__FILE__),
                                                       "../unitsdb/quantities.yaml")))
      @units = read_yaml("../unitsdb/units.yaml")
      @parser = parser
    end

    def read_yaml(path)
      yaml = YAML.load_file(File.join(File.join(File.dirname(__FILE__), path)))
      yaml.each_with_object({}) do |(k, v), m|
        next if v["name"].nil? || v["name"].empty?
        symbol = v["symbol"] || v["short"]
        m[symbol] = v
        m[symbol]["symbol"] = symbol
        m[symbol]["id"] = k
      end
    end

    def parser
      prefix = /#{@prefixes.keys.join("|")}/.r
      unit1 = /#{@units.keys.reject { |k| /\*|\^/.match(k) }.map { |k| Regexp.escape(k) }.join("|")}/.r
      exponent = /\^-?\d+/.r.map { |m| m.sub(/\^/, "") }
      multiplier = /\*/.r
      unit = seq(unit1, exponent._?) { |x| { prefix: nil, unit: x[0], exponent: x[1][0] } } |
        seq(prefix, unit1, exponent._?) { |x| { prefix: x[0][0], unit: x[1], exponent: x[2][0] } }
      units_tail = seq(multiplier, unit) { |u| u[1] }
      units = seq(unit, units_tail.star) { |x| [x[0], x[1]].flatten }
      parser = units.eof
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
      units = @parser.parse(x)
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end
      Rsec::Fail.reset
      warn "#{x}: #{@parser.parse(x)}"
      <<~END
      <unitsml xmlns='#{UNITSML_NS}'>#{x}</unitsml>
      END
    end
  end
end
