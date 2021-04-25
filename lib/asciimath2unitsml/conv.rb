require "asciimath"
require "nokogiri"
require "htmlentities"
require "yaml"
require "rsec"
require_relative "string"
require_relative "parse"
require_relative "render"
require_relative "unit"
require_relative "validate"

module Asciimath2UnitsML
  MATHML_NS = "http://www.w3.org/1998/Math/MathML".freeze
  UNITSML_NS = "https://schema.unitsml.org/unitsml/1.0".freeze

  class Conv
    def initialize(options = {})
      @dimensions_id = read_yaml("../unitsdb/dimensions.yaml")
        .each_with_object({}) do |(k, v), m|
        m[k.to_s] = UnitsDB::Dimension.new(k, v)
      end
      @prefixes_id = read_yaml("../unitsdb/prefixes.yaml")
        .each_with_object({}) do |(k, v), m|
        m[k] = UnitsDB::Prefix.new(k, v)
      end
      @prefixes = flip_name_and_symbol(@prefixes_id)
      @quantities = read_yaml("../unitsdb/quantities.yaml")
        .each_with_object({}) do |(k, v), m|
        m[k.to_s] = UnitsDB::Quantity.new(k, v)
      end
      @units_id = read_yaml("../unitsdb/units.yaml")
        .each_with_object({}) do |(k, v), m|
        m[k.to_s] = UnitsDB::Unit.new(k.to_s, v)
      end
      @units = flip_name_and_symbols(@units_id)
      @symbols = @units.each_with_object({}) do |(_k, v), m|
        v.symbolids.each { |x| m[x] = v.symbols_hash[x] }
      end
      @parser = parser
      @multiplier = multiplier(options[:multiplier] || "\u22c5")
    end

    def float_to_display(float)
      float.to_f.round(1).to_s.sub(/\.0$/, "")
    end

    def prefix(units)
      units.map { |u| u[:prefix] }.reject(&:nil?).uniq.map do |p|
        <<~END
          <Prefix xmlns='#{UNITSML_NS}' prefixBase='#{@prefixes[p].base}'
                  prefixPower='#{@prefixes[p].power}' xml:id='#{@prefixes[p].id}'>
            <PrefixName xml:lang="en">#{@prefixes[p].name}</PrefixName>
            <PrefixSymbol type="ASCII">#{@prefixes[p].ascii}</PrefixSymbol>
            <PrefixSymbol type="unicode">#{@prefixes[p].unicode}</PrefixSymbol>
            <PrefixSymbol type="LaTeX">#{@prefixes[p].latex}</PrefixSymbol>
            <PrefixSymbol type="HTML">#{htmlent @prefixes[p].html}</PrefixSymbol>
          </Prefix>
        END
      end.join("\n")
    end

    def dimension_components(dims)
      return if dims.nil? || dims.empty?

      <<~END
        <Dimension xmlns='#{UNITSML_NS}' xml:id="#{dim_id(dims)}">
        #{dims.map { |u| dimension1(u) }.join("\n")}
        </Dimension>
      END
    end

    U2D = {
      "m" => { dimension: "Length", order: 1, symbol: "L" },
      "g" => { dimension: "Mass", order: 2, symbol: "M" },
      "kg" => { dimension: "Mass", order: 2, symbol: "M" },
      "s" => { dimension: "Time", order: 3, symbol: "T" },
      "A" => { dimension: "ElectricCurrent", order: 4, symbol: "I" },
      "K" => { dimension: "ThermodynamicTemperature", order: 5,
               symbol: "Theta" },
      "degK" => { dimension: "ThermodynamicTemperature", order: 5,
                  symbol: "Theta" },
      "mol" => { dimension: "AmountOfSubstance", order: 6, symbol: "N" },
      "cd" => { dimension: "LuminousIntensity", order: 7, symbol: "J" },
      "deg" => { dimension: "PlaneAngle", order: 8, symbol: "Phi" },
    }.freeze

    def units2dimensions(units)
      norm = decompose_units(units)
      return if norm.any? do |u|
        u[:unit] == "unknown" || u[:prefix] == "unknown" || u[:unit].nil?
      end

      norm.map do |u|
        { dimension: U2D[u[:unit]][:dimension],
          unit: u[:unit],
          exponent: u[:exponent] || 1,
          symbol: U2D[u[:unit]][:symbol] }
      end.sort { |a, b| U2D[a[:unit]][:order] <=> U2D[b[:unit]][:order] }
    end

    def dimension1(u)
      %(<#{u[:dimension]} symbol="#{u[:symbol]}"
      powerNumerator="#{float_to_display(u[:exponent])}"/>)
    end

    def dim_id(dims)
      return nil if dims.nil? || dims.empty?

      dimhash = dims.each_with_object({}) { |h, m| m[h[:dimension]] = h }
      dimsvector = %w(Length Mass Time ElectricCurrent ThermodynamicTemperature
                      AmountOfSubstance LuminousIntensity PlaneAngle)
        .map { |h| dimhash.dig(h, :exponent) }.join(":")
      id = @dimensions_id&.values&.select { |d| d.vector == dimsvector }
        &.first&.id and return id.to_s
      "D_" + dims.map do |d|
        U2D[d[:unit]][:symbol] +
          (d[:exponent] == 1 ? "" : float_to_display(d[:exponent]))
      end.join("")
    end

    def decompose_units(units)
      gather_units(units_only(units).map { |u| decompose_unit(u) }.flatten)
    end

    def gather_units(units)
      units.sort_by { |a| a[:unit] }.each_with_object([]) do |k, m|
        if m.empty? || m[-1][:unit] != k[:unit] then m << k
        else
          m[-1] = {
            prefix: combine_prefixes(
              @prefixes[m[-1][:prefix]], @prefixes[k[:prefix]]
            ),
            unit: m[-1][:unit],
            exponent: (k[:exponent]&.to_f || 1) +
              (m[-1][:exponent]&.to_f || 1),
          }
        end
      end
    end

    # treat g not kg as base unit: we have stripped the prefix k in parsing
    # reduce units down to basic units
    def decompose_unit(u)
      if u[:unit].nil? then u
      elsif u[:unit] == "g" then u
      elsif @units[u[:unit]].system_type == "SI_base" then u
      elsif !@units[u[:unit]].si_derived_bases
        { prefix: u[:prefix], unit: "unknown", exponent: u[:exponent] }
      else
        @units[u[:unit]].si_derived_bases.each_with_object([]) do |k, m|
          prefix = if !k[:prefix].nil? && !k[:prefix].empty?
                     combine_prefixes(@prefixes_id[k[:prefix]],
                                      @prefixes[u[:prefix]])
                   else
                     u[:prefix]
                   end
          m << { prefix: prefix,
                 unit: @units_id[k[:id]].symbolid,
                 exponent: (k[:power]&.to_i || 1) * (u[:exponent]&.to_f || 1) }
        end
      end
    end

    def combine_prefixes(p1, p2)
      return nil if p1.nil? && p2.nil?
      return p1.symbolid if p2.nil?
      return p2.symbolid if p1.nil?
      return "unknown" if p1.base != p2.base

      @prefixes.each do |_, p|
        return p.symbolid if p.base == p1.base && p.power == p1.power + p2.power
      end
      "unknown"
    end

    def quantityname(id)
      ret = ""
      @quantities[id].names.each do |q|
        ret += %(<QuantityName xml:lang="en-US">#{q}</QuantityName>)
      end
      ret
    end

    def quantity(normtext, quantity)
      return unless @units[normtext] && @units[normtext].quantities.size == 1 ||
        @quantities[quantity]

      id = quantity || @units[normtext].quantities.first
      @units[normtext]&.dimension and
        dim = %( dimensionURL="##{@units[normtext].dimension}")
      <<~END
        <Quantity xmlns='#{UNITSML_NS}' xml:id="#{id}"#{dim} quantityType="base">
        #{quantityname(id)}
        </Quantity>
      END
    end

    def dimid2dimensions(normtext)
      @dimensions_id[normtext].keys.map do |k|
        { dimension: k,
          symbol: U2D.values.select { |v| v[:dimension] == k }.first[:symbol],
          exponent: @dimensions_id[normtext].exponent(k) }
      end
    end

    def dimension(normtext)
      return unless @units[normtext]&.dimension

      dims = dimid2dimensions(@units[normtext]&.dimension)
      <<~END
        <Dimension xmlns='#{UNITSML_NS}' xml:id="#{@units[normtext]&.dimension}">
        #{dims.map { |u| dimension1(u) }.join("\n")}
        </Dimension>
      END
    end

    def unitsml(units, origtext, normtext, quantity, name)
      dims = units2dimensions(units)
      <<~END
        #{unit(units, origtext, normtext, dims, name)}
        #{prefix(units)}
        #{dimension(normtext)}
        #{dimension_components(dims)}
        #{quantity(normtext, quantity)}
      END
    end
  end
end
