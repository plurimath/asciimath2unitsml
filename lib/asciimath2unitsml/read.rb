module Asciimath2UnitsML
  class Conv
    def read_yaml(path)
      validate_yaml(symbolize_keys(YAML
        .load_file(File.join(File.join(File.dirname(__FILE__), path)))), path)
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

    def flip_name_and_symbol(hash)
      hash.each_with_object({}) do |(_k, v), m|
        next if v.name.nil? || v.name.empty?

        m[v.symbolid] = v
      end
    end

    def flip_name_and_symbols(hash)
      hash.each_with_object({}) do |(_k, v), m|
        next if v.name.nil? || v.name.empty?

        v.symbolids.each { |s| m[s] = v }
      end
    end
  end
end
