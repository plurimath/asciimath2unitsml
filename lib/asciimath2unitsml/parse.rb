module Asciimath2UnitsML
  class Conv
    include Rsec::Helpers
    def parsers
      exponent = /\^\(-?\d+\)/.r.map { |m| m.sub(/\^/, "").gsub(/[()]/, "") } |
        /\^-?\d+/.r.map { |m| m.sub(/\^/, "") }
      multiplier = %r{\*|//|/}.r.map { |x| { multiplier: x[0] } }
      units = units_parse(exponent, multiplier)
      dimensions = dimensions_parser(exponent, multiplier)
      [units.eof, dimensions.eof]
    end

    def dimensions_parser(exponent, multiplier)
      dim1 = /#{@dimensions.keys.sort_by(&:length).reverse.join("|")}/.r
      dimension =
        seq("sqrt(", dim1, ")") { |x| { dim: x[1], display_exponent: "0.5" } } |
        seq(dim1, exponent._? & (multiplier | ")".r)) { |x| { dim: x[0], display_exponent: (x[1][0]) } } |
        seq(dim1, exponent._?).eof { |x| { dim: x[0], display_exponent: (x[1][0]) } }
      dimensions1 = "(".r >> lazy { dimensions } << ")" | dimension
      dimensions = dimensions1.join(multiplier) # rubocop:disable Style/RedundantAssignment
      dimensions
    end

    def units_parse(exponent, multiplier)
      prefix2 = /#{@prefixes.keys.select { |x| x.size == 2 }.join("|")}/.r
      prefix1 = /#{@prefixes.keys.select { |x| x.size == 1 }.join("|")}/.r
      unit_keys = @units.keys.reject do |k|
        /\*|\^|\/|^1$/.match(k) || @units[k].prefixed
      end.map { |k| Regexp.escape(k) }
      unit1 = /#{unit_keys.sort_by(&:length).reverse.join("|")}/.r

      unit =
        seq("sqrt(", unit1, ")") { |x| { prefix: nil, unit: x[1], display_exponent: "0.5" } } |
        seq("sqrt(", prefix1, unit1, ")") { |x| { prefix: x[1], unit: x[2], display_exponent: "0.5" } } |
        seq("sqrt(", prefix2, unit1, ")") { |x| { prefix: x[1], unit: x[2], display_exponent: "0.5" } } |
        seq(unit1, exponent._? & (multiplier | ")".r)) { |x| { prefix: nil, unit: x[0], display_exponent: (x[1][0]) } } |
        seq(unit1, exponent._?).eof { |x| { prefix: nil, unit: x[0], display_exponent: (x[1][0]) } } |
        seq(prefix1, unit1, exponent._?) { |x| { prefix: x[0], unit: x[1], display_exponent: (x[2][0]) } } |
        seq(prefix2, unit1, exponent._?) { |x| { prefix: x[0], unit: x[1], display_exponent: (x[2][0]) } } |
        "1".r.map { |_| { prefix: nil, unit: "1", display_exponent: nil } }
      units1 = "(".r >> lazy { units } << ")" | unit
      units = seq(prefix2, "-") { |x| [{ prefix: x[0], unit: nil, display_exponent: nil }] } | # rubocop:disable Style/RedundantAssignment
        seq(prefix1, "-") { |x| [{ prefix: x[0], unit: nil, display_exponent: nil }] } |
        units1.join(multiplier)
      units
    end

    def parse(expr)
      text = Array(expr.split(/,\s*/))
      if /dim_/.match?(text[0]) then parse_dimensions(text)
      else parse_units(text)
      end
    end

    def parse_units(text)
      units = @parser.parse!(text[0])
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end

      Rsec::Fail.reset
      postprocess(units, text, true)
    end

    def parse_dimensions(text)
      units = @dim_parser.parse!(text[0])
      if !units || Rsec::INVALID[units]
        raise Rsec::SyntaxError.new "error parsing UnitsML expression", x, 1, 0
      end

      Rsec::Fail.reset
      postprocess(units, text, false)
    end

    def postprocess(units, text, is_units)
      units = postprocess1(units.flatten)
      normtext = postprocess_normtext(units, is_units)
      [units, text[0], normtext, postprocess_extr(text, "quantity"),
       postprocess_extr(text, "name"), postprocess_extr(text, "symbol"),
       postprocess_extr(text, "multiplier")]
    end

    def postprocess_normtext(units, is_units)
      units_only(units).each.map do |u|
        if is_units then "#{u[:prefix]}#{u[:unit]}#{display_exp(u)}"
        else "#{u[:dim]}#{display_exp(u)}"
        end
      end.join("*")
    end

    def postprocess_extr(text, name)
      text[1..-1]&.select do |x|
        /^#{name}:/.match(x)
      end&.first&.sub(/^#{name}:\s*/, "")
    end

    def display_exp(unit)
      unit[:exponent] && unit[:exponent] != "1" ? "^#{unit[:exponent]}" : ""
    end

    def postprocess1(units)
      inverse = false
      units.each_with_object([]) do |u, m|
        if u[:multiplier]
          inverse = !inverse if u[:multiplier] == "/"
        else
          u[:exponent] =
            inverse ? "-#{u[:display_exponent] || '1'}" : u[:display_exponent]
          u[:exponent] = u[:exponent]&.sub(/^--+/, "")
        end
        m << u
      end
    end

    def Asciimath2UnitsML(expression)
      xml = Nokogiri::XML(asciimath2mathml(expression))
      MathML2UnitsML(xml).to_xml
    end

    # https://www.w3.org/TR/mathml-units/ section 2:
    # delimit number Invisible-Times unit
    def MathML2UnitsML(xml)
      xml.is_a? String and xml = Nokogiri::XML(xml)
      xml.xpath(".//m:mtext", "m" => MATHML_NS).each do |x|
        next unless %r{^unitsml\(.+\)$}.match?(x.text)

        text = x.text.sub(%r{^unitsml\((.+)\)$}m, "\\1")
        units, origtext, normtext, quantity, name, symbol, multiplier =
          parse(text)
        rendering = if symbol
                      embeddedmathml(asciimath2mathml(symbol))
                    else
                      mathmlsymbol(units, false, multiplier)
                    end
        x.replace("#{delimspace(rendering, x)}"\
                  "<mrow xref='#{unit_id(origtext)}'>#{rendering}</mrow>\n"\
                  "#{unitsml(units, origtext, normtext, quantity, name)}")
      end
      dedup_ids(xml)
    end

    # if previous sibling's last descendent non-whitespace is MathML and
    # mn or mi, no space
    def delimspace(rendering, elem)
      prec_text_elem =
        elem.xpath("./preceding-sibling::*[namespace-uri() = '#{MATHML_NS}']/"\
                   "descendant::text()[normalize-space()!='']"\
                   "[last()]/parent::*").last
      return "" if prec_text_elem.nil? ||
        !%w(mn mi).include?(prec_text_elem&.name)

      text = HTMLEntities.new.encode(Nokogiri::XML("<mrow>#{rendering}</mrow>")
        .text.strip)
      if /\p{L}|\p{N}/.match?(text)
        "<mo rspace='thickmathspace'>&#x2062;</mo>"
      else "<mo>&#x2062;</mo>"
      end
    end

    def dedup_ids(xml)
      %w(Unit Dimension Prefix Quantity).each do |t|
        xml.xpath(".//m:#{t}/@xml:id", "m" => UNITSML_NS).map(&:text)
          .uniq.each do |v|
          xml.xpath(".//*[@xml:id = '#{v}']").each_with_index do |n, i|
            next if i.zero?

            n.remove
          end
        end
      end
      xml
    end

    def asciimath2mathml(expression)
      AsciiMath::MathMLBuilder.new(msword: true).append_expression(
        AsciiMath.parse(HTMLEntities.new.decode(expression)).ast,
      ).to_s.gsub(/<math>/, "<math xmlns='#{MATHML_NS}'>")
    end

    def embeddedmathml(mathml)
      x = Nokogiri::XML(mathml)
      x.xpath(".//m:mi", "m" => MATHML_NS)
        .each { |mi| mi["mathvariant"] = "normal" }
      x.children.to_xml
    end

    def ambig_units
      u = @units_id.each_with_object({}) do |(_k, v), m|
        v.symbolids.each do |x|
          next if %r{[*/^]}.match?(x)
          next unless v.symbols_hash[x][:html] != x

          m[v.symbols_hash[x][:html]] ||= []
          m[v.symbols_hash[x][:html]] << x
        end
      end
      u.each_key { |k| u[k] = u[k].unshift(k) if @symbols.dig(k, :html) == k }
      render_ambig_units(u)
    end

    def render_ambig_units(u)
      maxcols = 0
      u.each { |_, v| maxcols = v.size if maxcols < v.size }
      puts %([cols="#{maxcols + 1}*"]\n|===\n|Symbol | Unit + ID #{'| ' * (maxcols - 1)}\n)
      puts "\n\n"
      u.keys.sort_by do |a|
        [-u[a].size, a.gsub(%r{&[^;]+;}, "")
          .gsub(/[^A-Za-z]/, "").downcase]
      end.each do |k|
        print "| #{html2adoc(k)} "
        u[k].sort_by(&:size).each { |v1| print "| #{@units[v1].name}: `#{v1}` " }
        puts "#{'| ' * (maxcols - u[k].size)}\n"
      end
      puts "|===\n"
    end

    def html2adoc(elem)
      elem.gsub(%r{<i>}, "__").gsub(%r{</i>}, "__")
        .gsub(%r{<sup>}, "^").gsub(%r{</sup>}, "^")
        .gsub(%r{<sub>}, "~").gsub(%r{</sub>}, "~")
    end
  end
end
