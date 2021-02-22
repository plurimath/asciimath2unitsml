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
      @prefixes_id = read_yaml("../unitsdb/prefixes.yaml")
      @prefixes = flip_name_and_id(@prefixes_id)
      @quantities = read_yaml("../unitsdb/quantities.yaml")
      @units_id = read_yaml("../unitsdb/units.yaml")
      @units = flip_name_and_id(@units_id)
      #temporary
      @units[:degC][:render] = "&#xB0;C"
      @units[:degF][:render] = "&#xB0;F"
      @units[:Ohm][:render] = "&#x3A9;"
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
        (@units[text.to_sym] ? @units[text.to_sym][:id] : text.gsub(/\*/, ".").gsub(/\^/, ""))
    end

    def unit(units, origtext, normtext, dims)
      dimid = dim_id(dims)
      <<~END
      <Unit xmlns='#{UNITSML_NS}' xml:id='#{unit_id(origtext)}'#{dimid ? " dimensionURL='##{dimid}'" : ""}>
      #{unitsystem(units)}
      #{unitname(units, normtext)}
      #{unitsymbol(units)}
      #{rootunits(units)}
      </Unit>
      END
    end

    def unitsystem(units)
      ret = []
      units = units_only(units)
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

    def render(unit)
      #require "byebug"; byebug if unit == "degC"
      @units[unit.to_sym][:render] || unit
    end

    def htmlsymbol(units)
      units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:html] : u[:multiplier]
        else
          u[:display_exponent] and exp = "<sup>#{u[:display_exponent].sub(/-/, "&#x2212;")}</sup>"
          "#{u[:prefix]}#{render(u[:unit])}#{exp}"
        end
      end.join("")
    end

    def mathmlsymbol(units)
      exp = units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:mathml] : "<mo>#{u[:multiplier]}</mo>"
        else
          base = "<mi mathvariant='normal'>#{u[:prefix]}#{render(u[:unit])}</mi>"
          if u[:display_exponent]
            exp = "<mn>#{u[:display_exponent]}</mn>".sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
            "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
          else
            base
          end
        end
      end.join("")
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
      exp = units_only(units).map do |u|
        prefix = " prefix='#{u[:prefix]}'" if u[:prefix]
        exponent = " powerNumerator='#{u[:exponent]}'" if u[:exponent] && u[:exponent] != "1"
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
      <Dimension xmlns='#{UNITSML_NS}' xml:id="#{dim_id(dims)}">
      #{dims.map { |u| dimension1(u) }.join("\n") }
      </Dimension>
      END
    end

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
      "D_" + dims.map { |d| U2D[d[:unit]][:symbol] + (d[:exponent] == 1 ? "" : d[:exponent].to_s) }.join("")
    end

    def normalise_units(units)
      gather_units(units_only(units).map { |u| normalise_unit(u) }.flatten)
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
