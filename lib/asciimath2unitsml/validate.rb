module Asciimath2UnitsML
  class Conv
    def validate_yaml(hash, path)
      return hash if path == "../unitsdb/quantities.yaml"
      return hash if path == "../unitsdb/dimensions.yaml"

      hash.each_with_object({}) do |(k, v), m|
        path == "../unitsdb/units.yaml" and validate_unit(v)
        m = validate_symbols(m, v)
        v[:unit_symbols]&.each { |s| validate_unit_symbol_cardinality(s, k) }
      end
      hash
    end

    def validate_unit(unit)
      if unit[:quantity_reference]
        unit[:quantity_reference].is_a?(Array) or
          raise StandardError
            .new "No quantity_reference array provided for unit: #{unit}"
      end
      if unit[:unit_name]
        unit[:unit_name].is_a?(Array) or
          raise StandardError
            .new "No unit_name array provided for unit: #{unit}"
      end
    end

    def validate_symbols(acc, val)
      symbol = symbol_key(val)
      !symbol.nil? or
        raise StandardError.new "No symbol provided for unit: #{val}"
      Array(symbol)&.each do |s|
        acc[s] && s != "1" and
          raise StandardError.new "symbol #{s} is not unique in #{val}: "\
          "already used for #{acc[s]}"
        acc[s] = val
      end
      acc
    end

    def validate_unit_symbol_cardinality(sym, key)
      return true if sym.nil?

      !sym[:id].nil? && !sym[:ascii].nil? && !sym[:html].nil? &&
        !sym[:mathml].nil? && !sym[:latex].nil? &&
        !sym[:unicode].nil? and return true
      raise StandardError.new "malformed unit_symbol for #{key}: #{sym}"
    end

    def symbol_key(val)
      symbol = val[:unit_symbols]&.each_with_object([]) do |s, m|
        m << (s["id"] || s[:id])
      end || val.dig(:symbol, :ascii) || val[:symbol] # || val[:short]
      !symbol.nil? && val[:unit_symbols] && !symbol.is_a?(Array) and
        symbol = [symbol]
      symbol
    end
  end
end
