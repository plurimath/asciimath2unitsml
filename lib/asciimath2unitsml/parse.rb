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
  end
end
