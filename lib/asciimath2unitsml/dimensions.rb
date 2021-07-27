module Asciimath2UnitsML
  class Conv
    def dimension_components(dims)
      return if dims.nil? || dims.empty?

      <<~XML
        <Dimension xmlns='#{UNITSML_NS}' xml:id="#{dim_id(dims)}">
        #{dims.map { |u| dimension1(u) }.join("\n")}
        </Dimension>
      XML
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
      "deg" => { dimension: "PlaneAngle", order: 8, symbol: "phi" },
    }.freeze

    Dim2D = {
      "dim_L" => U2D["m"],
      "dim_M" => U2D["g"],
      "dim_T" => U2D["s"],
      "dim_I" => U2D["A"],
      "dim_Theta" => U2D["K"],
      "dim_N" => U2D["mol"],
      "dim_J" => U2D["cd"],
      "dim_phi" => U2D["deg"],
    }.freeze

    def units2dimensions(units)
      norm = decompose_units(units)
      return units2dimensions_dim_input(norm) if norm[0][:dim]
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

    def units2dimensions_dim_input(norm)
      norm.map do |u|
        { dimension: Dim2D[u[:dim]][:dimension],
          exponent: u[:exponent] || 1,
          id: u[:dim],
          symbol: Dim2D[u[:dim]][:symbol] }
      end.sort { |a, b| Dim2D[a[:id]][:order] <=> Dim2D[b[:id]][:order] }
    end

    def dimension1(dim)
      %(<#{dim[:dimension]} symbol="#{dim[:symbol]}"
      powerNumerator="#{float_to_display(dim[:exponent])}"/>)
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
        (U2D.dig(d[:unit], :symbol) || Dim2D.dig(d[:id], :symbol)) +
          (d[:exponent] == 1 ? "" : float_to_display(d[:exponent]))
      end.join("")
    end

    def decompose_units(units)
      gather_units(units_only(units).map { |u| decompose_unit(u) }.flatten)
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
      <<~XML
        <Dimension xmlns='#{UNITSML_NS}' xml:id="#{@units[normtext]&.dimension}">
        #{dims.map { |u| dimension1(u) }.join("\n")}
        </Dimension>
      XML
    end

    def unitsml(units, origtext, normtext, quantity, name)
      dims = units2dimensions(units)
      <<~XML
        #{unit(units, origtext, normtext, dims, name)}
        #{prefix(units)}
        #{dimension(normtext)}
        #{dimension_components(dims)}
        #{quantity(normtext, quantity)}
      XML
    end
  end
end
