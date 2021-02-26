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
    def initialize(options = {})
      @dimensions_id = read_yaml("../unitsdb/dimensions.yaml").each_with_object({}) do |(k, v), m|
        m[k] = UnitsDB::Dimension.new(k, v)
      end
      @prefixes_id = read_yaml("../unitsdb/prefixes.yaml").each_with_object({}) do |(k, v), m|
        m[k] = UnitsDB::Prefix.new(k, v)
      end
      @prefixes = flip_name_and_symbol(@prefixes_id)
      @quantities = read_yaml("../unitsdb/quantities.yaml").each_with_object({}) do |(k, v), m|
        m[k] = UnitsDB::Quantity.new(k, v)
      end
      @units_id = read_yaml("../unitsdb/units.yaml").each_with_object({}) do |(k, v), m|
        m[k.to_s] = UnitsDB::Unit.new(k.to_s, v)
      end
      @units = flip_name_and_symbols(@units_id)
      @symbols = @units.each_with_object({}) do |(k, v), m|
        v.symbolids.each { |x| m[x] = v.symbols_hash[x] }
      end
      @parser = parser
      @multiplier = multiplier(options[:multiplier] || "\u00b7")
    end

    def multiplier(x)
      case x
      when :space
        { html: "&#xA0;", mathml: "<mo rspace='thickmathspace'>&#x2062;</mo>" }
      when :nospace
        { html: "", mathml: "<mo>&#x2062;</mo>" }
      else
        { html: HTMLEntities.new.encode(x), mathml: "<mo>#{HTMLEntities.new.encode(x)}</mo>" }
      end
    end

    def units_only(units)
      units.reject { |u| u[:multiplier] }
    end

    def unit_id(text)
      text = text.gsub(/[()]/, "")
      "U_" +
        (@units[text] ? @units[text].id : text.gsub(/\*/, ".").gsub(/\^/, ""))
    end

    def unit(units, origtext, normtext, dims)
      dimid = dim_id(dims)
      norm_units = normalise_units(units)
      <<~END
      <Unit xmlns='#{UNITSML_NS}' xml:id='#{unit_id(normtext)}'#{dimid ? " dimensionURL='##{dimid}'" : ""}>
      #{unitsystem(units)}
      #{unitname(norm_units, normtext)}
      #{unitsymbol(norm_units)}
      #{rootunits(units)}
      </Unit>
      END
    end

    def normalise_units(units)
      units.map do |u|
        u1 = u.dup
        u1[:multiplier] and u1[:multiplier] = "*"
        u1[:exponent] and u1[:display_exponent] = u1[:exponent]
        u1
      end
    end

    # kg exception
    def unitsystem(units)
      ret = []
      units = units_only(units)
      units.any? { |x| @units[x[:unit]].system_name != "SI" } and
        ret << "<UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>"
      if units.any? { |x| @units[x[:unit]].system_name == "SI" }
        base = units.size == 1 && @units[units[0][:unit]].system_type == "SI-base"
        base = true if units.size == 1 && units[0][:unit] == "g" && units[0][:prefix] == "k"
        ret << "<UnitSystem name='SI' type='#{base ? "SI_base" : "SI_derived"}' xml:lang='en-US'/>"
      end
      ret.join("\n")
    end

    def unitname(units, text)
      name = @units[text] ? @units[text].name : compose_name(units, text)
      "<UnitName xml:lang='en'>#{name}</UnitName>"
    end

    # TODO: compose name from the component units
    def compose_name(units, text)
      text
    end

    def unitsymbol(units)
      <<~END
      <UnitSymbol type="HTML">#{htmlsymbol(units, true)}</UnitSymbol>
      <UnitSymbol type="MathML">#{mathmlsymbolwrap(units, true)}</UnitSymbol>
      END
    end

    def render(unit, style)
      @symbols[unit][style] || unit
    end

    def htmlsymbol(units, normalise)
      units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:html] : u[:multiplier]
        else
          u[:display_exponent] and exp = "<sup>#{u[:display_exponent].sub(/-/, "&#x2212;")}</sup>"
          base = render(normalise ? @units[u[:unit]].symbolid : u[:unit], :html)
          "#{u[:prefix]}#{base}#{exp}"
        end
      end.join("")
    end

    def mathmlsymbol(units, normalise)
      exp = units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:mathml] : "<mo>#{u[:multiplier]}</mo>"
        else
          base = render(normalise ? @units[u[:unit]].symbolid : u[:unit], :mathml)
          if u[:prefix]
            base = base.match(/<mi mathvariant='normal'>/) ?
              base.sub(/<mi mathvariant='normal'>/, "<mi mathvariant='normal'>#{u[:prefix]}") :
              "<mrow><mi mathvariant='normal'>#{u[:prefix]}#{base}</mrow>"
          end
          if u[:display_exponent]
            exp = "<mn>#{u[:display_exponent]}</mn>".sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
            base = "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
          end
          base
        end
      end.join("")
    end

    def mathmlsymbolwrap(units, normalise)
      <<~END
      <math xmlns='#{MATHML_NS}'><mrow>#{mathmlsymbol(units, normalise)}</mrow></math>
      END
    end

    def rootunits(units)
      return if units.size == 1
      exp = units_only(units).map do |u|
        prefix = " prefix='#{u[:prefix]}'" if u[:prefix]
        exponent = " powerNumerator='#{u[:exponent]}'" if u[:exponent] && u[:exponent] != "1"
        "<EnumeratedRootUnit unit='#{@units[u[:unit]].name}'#{prefix}#{exponent}/>"
      end.join("\n")
      <<~END
      <RootUnits>#{exp}</RootUnits>
      END
    end

    def prefix(units)
      units.map { |u| u[:prefix] }.reject { |u| u.nil? }.uniq.map do |p|
        <<~END
        <Prefix xmlns='#{UNITSML_NS}' prefixBase='#{@prefixes[p].base}'
                prefixPower='#{@prefixes[p].power}' xml:id='#{@prefixes[p].id}'>
          <PrefixName xml:lang="en">#{@prefixes[p].name}</PrefixName>
          <PrefixSymbol type="ASCII">#{@prefixes[p].ascii}</PrefixSymbol>
          <PrefixSymbol type="unicode">#{@prefixes[p].unicode}</PrefixSymbol>
          <PrefixSymbol type="LaTeX">#{@prefixes[p].latex}</PrefixSymbol>
          <PrefixSymbol type="HTML">#{HTMLEntities.new.encode(@prefixes[p].html, :basic)}</PrefixSymbol>
        </Prefix>
        END
      end.join("\n")
    end

    def dimension(dims)
      return if dims.nil? || dims.empty?
      <<~END
      <Dimension xmlns='#{UNITSML_NS}' xml:id="#{dim_id(dims)}">
      #{dims.map { |u| dimension1(u) }.join("\n") }
      </Dimension>
      END
    end

    def units2dimensions(units)
      norm = decompose_units(units)
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
      "D_" + dims.map { |d| U2D[d[:unit]][:symbol] + (d[:exponent] == 1 ? "" : d[:exponent].to_s) }.join("")
    end

    def decompose_units(units)
      gather_units(units_only(units).map { |u| decompose_unit(u) }.flatten)
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

    # treat g not kg as base unit: we have stripped the prefix k in parsing
    # reduce units down to basic units
    def decompose_unit(u)
      if u[:unit] == "g" then u
      elsif @units[u[:unit]].system_type == "SI_base" then u
      elsif !@units[u[:unit]].si_derived_bases
        { prefix: u[:prefix], unit: "unknown", exponent: u[:exponent] }
      else
        @units[u[:unit]].si_derived_bases.each_with_object([]) do |k, m|
          m << { prefix: !k[:prefix].nil? && !k[:prefix].empty? ? 
                 combine_prefixes(@prefixes_id[k[:prefix]], @prefixes[u[:prefix]]) : u[:prefix],
                 unit: @units_id[k[:id]].symbolid,
                 exponent: (k[:power]&.to_i || 1) * (u[:exponent]&.to_i || 1) }
        end
      end
    end

    def combine_prefixes(p1, p2)
      return nil if p1.nil? && p2.nil?
      return p1.symbolid if p2.nil?
      return p2.symbolid if p1.nil?
      return "unknown" if p1.base != p2.base
      @prefixes.each do |p|
        return p.symbolid if p.base == p1.base && p.power == p1.power + p2.power
      end
      "unknown"
    end

    def unitsml(units, origtext, normtext)
      dims = units2dimensions(units)
      <<~END
      #{unit(units, origtext, normtext, dims)}
      #{prefix(units)}
      #{dimension(dims)}
      END
    end
  end
end
