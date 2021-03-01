module Asciimath2UnitsML
  class Conv
    include Rsec::Helpers

    def read_yaml(path)
      validate_yaml(symbolize_keys(YAML.load_file(File.join(File.join(File.dirname(__FILE__), path)))), path)
    end

    def flip_name_and_symbol(hash)
      hash.each_with_object({}) do |(k, v), m|
        next if v.name.nil? || v.name.empty?
        m[v.symbolid] = v
      end
    end

    def flip_name_and_symbols(hash)
      hash.each_with_object({}) do |(k, v), m|
        next if v.name.nil? || v.name.empty?
        v.symbolids.each { |s| m[s] = v }
      end
    end

    def validate_yaml(hash, path)
      return hash if path == "../unitsdb/quantities.yaml"
      return hash if path == "../unitsdb/dimensions.yaml"
      hash.each_with_object({}) do |(k, v), m|
        symbol = symbol_key(v)
        !symbol.nil? or raise StandardError.new "No symbol provided for unit: #{v}"
        Array(symbol)&.each do |s|
          m[s] && s != "1" and
            raise StandardError.new "symbol #{s} is not unique in #{v}: already used for #{m[s]}"
          m[s] = v
        end
        v[:unit_symbols]&.each { |s| validate_unit_symbol_cardinality(s, k) }
      end
      hash
    end

    def validate_unit_symbol_cardinality(us, k)
      return true if us.nil?
      !us[:id].nil? && !us[:ascii].nil? && !us[:html].nil? && !us[:mathml].nil? && !us[:latex].nil? &&
        !us[:unicode].nil? and return true
      raise StandardError.new "malformed unit_symbol for #{k}: #{us}"
    end

    def symbol_key(v)
      symbol = v[:unit_symbols]&.each_with_object([]) { |s, m| m << (s["id"] || s[:id]) } || 
        v.dig(:symbol, :ascii) || v[:symbol] #|| v[:short]
      symbol = [symbol] if !symbol.nil? && v[:unit_symbols] && !symbol.is_a?(Array)
      symbol
    end

    def symbolize_keys(hash)
      return hash if hash.is_a? String
      hash.inject({}) do |result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    when Array then value.map { |m| symbolize_keys(m) }
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end

    def parser
      prefix2 = /#{@prefixes.keys.select { |x| x.size == 2 }.join("|")}/.r
      prefix1 = /#{@prefixes.keys.select { |x| x.size == 1 }.join("|")}/.r
      unit_keys = @units.keys.reject do |k|
        @units[k].root&.any? { |x| x[:prefix] } || /\*|\^|\//.match(k) || @units[k].prefixed
      end.map { |k| Regexp.escape(k) }
      unit1 = /#{unit_keys.sort_by(&:length).reverse.join("|")}/.r
      exponent = /\^\(-?\d+\)/.r.map { |m| m.sub(/\^/, "").gsub(/[()]/, "") } |
        /\^-?\d+/.r.map { |m| m.sub(/\^/, "") }
      multiplier = %r{\*|//|/}.r.map { |x| { multiplier: x[0] } }
      unit = 
        seq(unit1, exponent._? & multiplier) { |x| { prefix: nil, unit: x[0], display_exponent: (x[1][0] )} } |
        seq(unit1, exponent._?).eof { |x| { prefix: nil, unit: x[0], display_exponent: (x[1][0] )} } |
        seq(prefix1, unit1, exponent._? ) { |x| { prefix: x[0], unit: x[1], display_exponent: (x[2][0] ) } } |
        seq(prefix2, unit1, exponent._? ) { |x| { prefix: x[0], unit: x[1], display_exponent: (x[2][0] ) } }
      units = unit.join(multiplier)
      parser = units.eof
    end

    def parse(x)
      units = @parser.parse!(x)
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end
      Rsec::Fail.reset
      postprocess(units, x)
    end

    def postprocess(units, text)
      units = postprocess1(units)
      normtext = units_only(units).each.map do |u|
        exp = u[:exponent] && u[:exponent] != "1" ? "^#{u[:exponent]}" : ""
        "#{u[:prefix]}#{u[:unit]}#{exp}"
      end.join("*")
      [units, text, normtext]
    end

    def postprocess1(units)
      inverse = false
      units.each_with_object([]) do |u, m| 
        if u[:multiplier]
          inverse = (u[:multiplier] == "/")
        else
          u[:exponent] = inverse ? "-#{u[:display_exponent] || '1'}" : u[:display_exponent]
          u[:exponent] = u[:exponent]&.sub(/^--+/, "")
        end
        m << u
      end
    end

    U2D = {
      "m" => { dimension: "Length", order: 1, symbol: "L" },
      "g" => { dimension: "Mass", order: 2, symbol: "M" },
      "kg" => { dimension: "Mass", order: 2, symbol: "M" },
      "s" => { dimension: "Time", order: 3, symbol: "T" },
      "A" => { dimension: "ElectricCurrent", order: 4, symbol: "I" },
      "K" => { dimension: "ThermodynamicTemperature", order: 5, symbol: "Theta" },
      "degK" => { dimension: "ThermodynamicTemperature", order: 5, symbol: "Theta" },
      "mol" => { dimension: "AmountOfSubstance", order: 6, symbol: "N" },
      "cd" => { dimension: "LuminousIntensity", order: 7, symbol: "J" },
    }

    def Asciimath2UnitsML(expression)
      xml = Nokogiri::XML(asciimath2mathml(expression))
      MathML2UnitsML(xml).to_xml
    end

    # https://www.w3.org/TR/mathml-units/ section 2: delimit number Invisible-Times unit
    def MathML2UnitsML(xml)
      xml.is_a? String and xml = Nokogiri::XML(xml)
      xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
        next unless %r{^unitsml\(.+\)$}.match(x.text)
        text = x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")
        units, origtext, normtext = parse(text)
        delim = x&.previous_element&.name == "mn" ? "<mo rspace='thickmathspace'>&#x2062;</mo>" : ""
        x.replace("#{delim}<mrow xref='#{unit_id(text)}'>#{mathmlsymbol(units, false)}</mrow>\n"\
                  "#{unitsml(units, origtext, normtext)}")
      end
      dedup_ids(xml)
    end

    def dedup_ids(xml)
      %w(Unit Dimension Prefix Quantity).each do |t|
        xml.xpath(".//m:#{t}/@xml:id", "m" => UNITSML_NS).map { |a| a.text }.uniq.each do |v|
          xml.xpath(".//*[@xml:id = '#{v}']").each_with_index do |n, i|
            next if i == 0
            n.remove
          end
        end
      end
      xml
    end

    def asciimath2mathml(expression)
      AsciiMath::MathMLBuilder.new(:msword => true).append_expression(
        AsciiMath.parse(HTMLEntities.new.decode(expression)).ast).to_s.
      gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
    end
  end
end
