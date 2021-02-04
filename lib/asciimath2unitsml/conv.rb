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
      @prefixes_id = read_yaml("../unitsdb/prefixes.yaml")
      @prefixes = flip_name_and_id(@prefixes_id)
      @quantities = read_yaml("../unitsdb/quantities.yaml")
      @units_id = read_yaml("../unitsdb/units.yaml")
      @units = flip_name_and_id(@units_id)
      @parser = parser
    end

    def read_yaml(path)
      symbolize_keys(YAML.load_file(File.join(File.join(File.dirname(__FILE__), path))))
    end

    def flip_name_and_id(yaml)
      yaml.each_with_object({}) do |(k, v), m|
        next if v[:name].nil? || v[:name].empty?
        symbol = v[:symbol] || v[:short]
        m[symbol.to_sym] = v
        m[symbol.to_sym][:symbol] = symbol
        m[symbol.to_sym][:id] = k.to_s
      end
    end

    def symbolize_keys(hash)
      hash.inject({})do |result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end

    def parser
      prefix = /#{@prefixes.keys.join("|")}/.r
      unit_keys = @units.keys.reject do |k|
        @units[k][:type]&.include?("buildable") || /\*|\^/.match(k)
      end.map { |k| Regexp.escape(k) }
      unit1 = /#{unit_keys.join("|")}/.r
      exponent = /\^-?\d+/.r.map { |m| m.sub(/\^/, "") }
      multiplier = /\*/.r
      unit = seq(unit1, exponent._?) { |x| { prefix: nil, unit: x[0], exponent: x[1][0] } } |
        seq(prefix, unit1, exponent._?) { |x| { prefix: x[0][0], unit: x[1], exponent: x[2][0] } }
      units_tail = seq(multiplier, unit) { |u| u[1] }
      units = seq(unit, units_tail.star) { |x| [x[0], x[1]].flatten }
      parser = units.eof
    end

    # https://www.w3.org/TR/mathml-units/ section 2: delimit number Invisible-Times unit
    def Asciimath2UnitsML(expression)
      xml = Nokogiri::XML(asciimath2mathml(expression))
      xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
        next unless %r{^unitsml\(.+\)$}.match(x.text)
        text = x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")
        units = parse(text)
        delim = x&.previous_element&.name == "mn" ? "<mo rspace='thickmathspace'>&#x2062;</mo>" : ""
        x.replace("#{delim}<mrow xref='#{id(text)}'>#{mathmlsymbol(units)}</mrow>\n#{unitsml(units, text)}")
      end
      xml.to_xml
    end

    def UnitsML2MathML(x)
      x
    end

    def asciimath2mathml(expression)
      AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
        AsciiMath.parse(HTMLEntities.new.decode(expression)).ast).to_s.
      gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
    end

    def id(text)
      @units[text.to_sym] ? @units[text.to_sym][:id] : text.gsub(/\*/, ".").gsub(/\^/, "")
    end

    def unit(units, text)
      <<~END
      <Unit xmlns='#{UNITSML_NS}' xml:id='#{id(text)}'>
      #{unitsystem(units)}
      #{unitname(units, text)}
      #{unitsymbol(units)}
      #{rootunits(units)}
      </Unit>
      END
    end

    def unitsystem(units)
      ret = []
      units.any? { |x| @units[x[:unit].to_sym][:si] != true } and
        ret << "<UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>"
      if units.any? { |x| @units[x[:unit].to_sym][:si] == true }
        if units.size > 1
          ret << "<UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>"
        else
          base = @units[units[0][:unit].to_sym][:type].include?("si-base")
          ret << "<UnitSystem name='SI' type='#{base ? "SI_base" : "SI_derived"}' xml:lang='en-US'/>"
        end
      end
      ret.join("\n")
    end

    def unitname(units, text)
      name = @units[text.to_sym] ? @units[text.to_sym][:name] : compose_name(units, text)
      "<UnitName xml:lang='en'>#{name}</UnitName>"
    end

    # TODO: compose name from the component units
    def compose_name(units, text)
      text
    end

    def unitsymbol(units)
      <<~END
      <UnitSymbol type="HTML">#{htmlsymbol(units)}</UnitSymbol>
      <UnitSymbol type="MathML">#{mathmlsymbolwrap(units)}</UnitSymbol>
      END
    end

    def htmlsymbol(units)
      units.map do |u|
        u[:exponent] and exp = "<sup>#{u[:exponent].sub(/-/, "&#x2212;")}</sup>"
        "#{u[:prefix]}#{u[:unit]}#{exp}"
      end.join(" &#183; ")
    end

    def mathmlsymbol(units)
      exp = units.map do |u|
        base = "<mi mathvariant='normal'>#{u[:prefix]}#{u[:unit]}</mi>"
        if u[:exponent]
          exp = "<mn>#{u[:exponent]}</mn>".sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
          "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
        else
          base
        end
      end.join("<mo>&#xB7;</mo>")
    end

    def mathmlsymbolwrap(units)
      <<~END
      <math xmlns='#{MATHML_NS}'>
      <mrow>#{mathmlsymbol(units)}</mrow>
      </math>
      END
    end

    def rootunits(units)
      return if units.size == 1
      exp = units.map do |u|
        prefix = " prefix='#{u[:prefix]}'" if u[:prefix]
        exponent = " powerNumerator='#{u[:exponent]}'" if u[:exponent]
        "<EnumeratedRootUnit unit='#{@units[u[:unit].to_sym][:name]}'#{prefix}#{exponent}/>"
      end.join("\n")
      <<~END
      <RootUnits>#{exp}</RootUnits>
      END
    end

    def prefix(units)
      units.map { |u| u[:prefix] }.reject { |u| u.nil? }.uniq.map do |p1|
        p = p1.to_sym
        <<~END
        <Prefix xmlns='#{UNITSML_NS}' prefixBase='#{@prefixes[p][:base]}'
                prefixPower='#{@prefixes[p][:power]}' xml:id='#{@prefixes[p][:id]}'>
          <PrefixName xml:lang="en">#{@prefixes[p][:name]}</PrefixName>
          <PrefixSymbol type="ASCII">#{@prefixes[p][:symbol]}</PrefixSymbol>
        </Prefix>
        END
      end.join("\n")
    end

    def dimension(units)
    end

    def parse(x)
      units = @parser.parse(x)
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end
      Rsec::Fail.reset
      units
    end

    def unitsml(units, text)
      <<~END
      #{unit(units, text)}
      #{prefix(units)}
      #{dimension(units)}
      END
    end
  end
end
