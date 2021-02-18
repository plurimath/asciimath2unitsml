module Asciimath2UnitsML
  class Conv
    include Rsec::Helpers

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
      unit1 = /#{unit_keys.sort_by(&:length).reverse.join("|")}/.r
      exponent = /\^-?\d+/.r.map { |m| m.sub(/\^/, "") }
      multiplier = /\*/.r
      unit = seq(unit1, exponent._?) { |x| { prefix: nil, unit: x[0], exponent: x[1][0] } } |
        seq(prefix, unit1, exponent._?) { |x| { prefix: x[0][0], unit: x[1], exponent: x[2][0] } }
      units_tail = seq(multiplier, unit) { |u| u[1] }
      units = seq(unit, units_tail.star) { |x| [x[0], x[1]].flatten }
      parser = units.eof
    end

    def parse(x)
      units = @parser.parse(x)
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end
      Rsec::Fail.reset
      units
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

    def Asciimath2UnitsML(expression)
      xml = Nokogiri::XML(asciimath2mathml(expression))
      MathML2UnitsML(xml).to_xml
    end

    # https://www.w3.org/TR/mathml-units/ section 2: delimit number Invisible-Times unit
    def MathML2UnitsML(xml)
      xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
        next unless %r{^unitsml\(.+\)$}.match(x.text)
        text = x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")
        units = parse(text)
        delim = x&.previous_element&.name == "mn" ? "<mo rspace='thickmathspace'>&#x2062;</mo>" : ""
        x.replace("#{delim}<mrow xref='#{unit_id(text)}'>#{mathmlsymbol(units)}</mrow>\n#{unitsml(units, text)}")
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
