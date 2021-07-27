module Asciimath2UnitsML
  class Conv
    def units_only(units)
      units.reject { |u| u[:multiplier] }
    end

    def unit_id(text)
      text = text.gsub(/[()]/, "")
      /-$/.match(text) and return @prefixes[text.sub(/-$/, "")].id
      "U_#{@units[text] ? @units[text].id.gsub(/'/, '_') : text.gsub(/\*/, '.').gsub(/\^/, '')}"
    end

    def unit(units, _origtext, normtext, dims, name)
      return if units_only(units).any? { |x| x[:unit].nil? }

      dimid = dim_id(dims)
      norm_units = normalise_units(units)
      <<~XML
        <Unit xmlns='#{UNITSML_NS}' xml:id='#{unit_id(normtext)}'#{dimid ? " dimensionURL='##{dimid}'" : ''}>
        #{unitsystem(units)}
        #{unitname(norm_units, normtext, name)}
        #{unitsymbol(norm_units)}
        #{rootunits(units)}
        </Unit>
      XML
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
      return if units_only(units).any? { |x| x[:unit].nil? }

      ret = []
      units = units_only(units)
      units.any? { |x| @units[x[:unit]].system_name != "SI" } and
        ret << "<UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>"
      if units.any? { |x| @units[x[:unit]].system_name == "SI" }
        base = units.size == 1 &&
          @units[units[0][:unit]].system_type == "SI-base"
        base = true if units.size == 1 && units[0][:unit] == "g" &&
          units[0][:prefix] == "k"
        ret << "<UnitSystem name='SI' type='#{base ? 'SI_base' : 'SI_derived'}' xml:lang='en-US'/>"
      end
      ret.join("\n")
    end

    def unitname(units, text, name)
      name ||= @units[text] ? @units[text].name : compose_name(units, text)
      "<UnitName xml:lang='en'>#{name}</UnitName>"
    end

    # TODO: compose name from the component units
    def compose_name(_units, text)
      text
    end

    def unitsymbol(units)
      <<~XML
        <UnitSymbol type="HTML">#{htmlsymbol(units, true)}</UnitSymbol>
        <UnitSymbol type="MathML">#{mathmlsymbolwrap(units, true)}</UnitSymbol>
      XML
    end

    def rootunits(units)
      return if units_only(units).any? { |x| x[:unit].nil? }
      return if units.size == 1 && !units[0][:prefix]

      exp = units_only(units).map do |u|
        prefix = " prefix='#{u[:prefix]}'" if u[:prefix]
        u[:exponent] && u[:exponent] != "1" and
          arg = " powerNumerator='#{u[:exponent]}'"
        "<EnumeratedRootUnit unit='#{@units[u[:unit]].name}'#{prefix}#{arg}/>"
      end.join("\n")
      <<~XML
        <RootUnits>#{exp}</RootUnits>
      XML
    end
  end
end
