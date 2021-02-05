require "asciimath"
require "nokogiri"
require "htmlentities"
require "yaml"
require "rsec"
require_relative "string"
require_relative "parse"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze
  UNITSML_NS = "http://unitsml.nist.gov/2005".freeze

  class Conv
    def initialize
      @prefixes_id = read_yaml("../unitsdb/prefixes.yaml")
      @prefixes = flip_name_and_id(@prefixes_id)
      @quantities = read_yaml("../unitsdb/quantities.yaml")
      @units_id = read_yaml("../unitsdb/units.yaml")
      @units = flip_name_and_id(@units_id)
      @parser = parser
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

    def asciimath2mathml(expression)
      AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
        AsciiMath.parse(HTMLEntities.new.decode(expression)).ast).to_s.
      gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
    end

    def id(text)
      @units[text.to_sym] ? @units[text.to_sym][:id] : text.gsub(/\*/, ".").gsub(/\^/, "")
    end

    def unit(units, text, dims)
      dimid = dim_id(dims)
      <<~END
      <Unit xmlns='#{UNITSML_NS}' xml:id='#{id(text)}'#{dimid ? " dimensionURL='##{dimid}'" : ""}>
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
        base = units.size == 1 && @units[units[0][:unit].to_sym][:type].include?("si-base")
        ret << "<UnitSystem name='SI' type='#{base ? "SI_base" : "SI_derived"}' xml:lang='en-US'/>"
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

    def dimension(dims)
      return if dims.nil? || dims.empty?
      <<~END
      <Dimension xml:id="#{dim_id(dims)}">
      #{dims.map { |u| dimension1(u) }.join("\n") }
      </Dimension>
      END
    end

    U2D = {
      "m" => { dimension: "Length", order: 1, symbol: "L" },
      "g" => { dimension: "Mass", order: 2, symbol: "M" },
      "kg" => { dimension: "Mass", order: 2, symbol: "M" },
      "s" => { dimension: "Time", order: 3, symbol: "T" },
      "A" => { dimension: "ElectricCurrent", order: 4, symbol: "I" },
      "K" => { dimension: "ThermodynamicTemperature", order: 5, symbol: "Theta" },
      "mol" => { dimension: "AmountOfSubstance", order: 6, symbol: "N" },
      "cd" => { dimension: "LuminousIntensity", order: 7, symbol: "J" },
    }

    def units2dimensions(units)
      norm = normalise_units(units)
      return if norm.any? { |u| u[:unit] == "unknown" || u[:prefix] == "unknown" }
      norm.map do |u|
        { dimension: U2D[u[:unit]][:dimension],
          unit: u[:unit],
          exponent: u[:exponent] || 1,
          symbol: U2D[u[:unit]][:symbol] } 
      end.sort { |a, b| U2D[a[:unit]][:order] <=> U2D[b[:unit]][:order] }
    end

    def dimension1(u)
      %(<#{u[:dimension]} symbol="#{u[:symbol]}" powerNumerator="#{u[:exponent]}"/>)
    end

    def dim_id(dims)
      return nil if dims.nil? || dims.empty?
      dims.map { |d| U2D[d[:unit]][:symbol] + (d[:exponent] == 1 ? "" : d[:exponent].to_s) }.join("")
    end

    def normalise_units(units)
      gather_units(units.map { |u| normalise_unit(u) }.flatten)
    end

    def gather_units(units)
      units.sort { |a, b| a[:unit] <=> b[:unit] }.each_with_object([]) do |k, m|
        if m.empty? || m[-1][:unit] != k[:unit] then m << k
        else
          m[-1] = { prefix: combine_prefixes(@prefixes[m[-1][:prefix]], @prefixes[k[:prefix]]),
                    unit: m[-1][:unit],
                    exponent: (k[:exponent]&.to_i || 1) + (m[-1][:exponent]&.to_i || 1) }
        end
      end
    end

    def normalise_unit(u)
      if @units[u[:unit].to_sym][:type]&.include?("si-base") then u
      elsif !@units[u[:unit].to_sym][:bases] then { prefix: u[:prefix], unit: "unknown", exponent: u[:exponent] }
      else
        @units[u[:unit].to_sym][:bases].each_with_object([]) do |k, m|
          m << { prefix: k["prefix"] ?
                 combine_prefixes(@prefixes_id[k["prefix"]], @prefixes[u[:prefix]]) : u[:prefix],
                 unit: @units_id[k["id"].to_sym][:symbol],
                 exponent: (k["power"]&.to_i || 1) * (u[:exponent]&.to_i || 1) }
        end
      end
    end

    def combine_prefixes(p1, p2)
      return nil if p1.nil? && p2.nil?
      return p1[:symbol] if p2.nil?
      return p2[:symbol] if p1.nil?
      return "unknown" if p1[:base] != p2[:base]
      @prefixes.each do |p|
        return p[:symbol] if p[:base] == p1[:base] && p[:power] == p1[:power] + p2[:power]
      end
      "unknown"
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
      dims = units2dimensions(units)
      <<~END
      #{unit(units, text, dims)}
      #{prefix(units)}
      #{dimension(dims)}
      END
    end
  end
end
