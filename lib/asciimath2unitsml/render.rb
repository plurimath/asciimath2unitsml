module Asciimath2UnitsML
  class Conv
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

    def render(unit, style)
      @symbols[unit][style] || unit
    end

    def htmlent(x)
      HTMLEntities.new.decode(x).split(/([<>&])/)
        .map { |c| /[<>'"]/.match(c) ? c : HTMLEntities.new.encode(c, :hexadecimal) }.join
    end

    def htmlsymbol(units, normalise)
      units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:html] : u[:multiplier]
        elsif u[:unit].nil? && u[:prefix]
          @prefixes[u[:prefix]].html
        else
          base = (u[:prefix] || "") + render(normalise ? @units[u[:unit]].symbolid : u[:unit], :html)
          htmlsymbol_exponent(u, base)
        end
      end.join("")
    end

    def htmlsymbol_exponent(u, base)
      if u[:display_exponent] == "0.5"
        base = "&#x221a;#{base}"
      elsif u[:display_exponent]
        exp = "<sup>#{u[:display_exponent].sub(/-/, "&#x2212;")}</sup>"
        base += exp
      end
      base
    end

    def mathmlsymbol(units, normalise)
      exp = units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:mathml] : "<mo>#{u[:multiplier]}</mo>"
        elsif u[:unit].nil? && u[:prefix]
          %(<mi mathvariant='normal'>#{htmlent(@prefixes[u[:prefix]].html)}</mi>)
        else
          mathmlsymbol1(u, normalise)
        end
      end.join("")
    end

    def mathmlsymbol1(u, normalise)
      base = render(normalise ? @units[u[:unit]].symbolid : u[:unit], :mathml)
      if u[:prefix]
        prefix = htmlent(@prefixes[u[:prefix]].html)
        base = base.match(/<mi mathvariant='normal'>/) ?
          base.sub(/<mi mathvariant='normal'>/, "<mi mathvariant='normal'>#{prefix}") :
          "<mrow><mi mathvariant='normal'>#{prefix}#{base}</mrow>"
      end
      mathmlsymbol_exponent(u, base)
    end

    def mathmlsymbol_exponent(u, base)
      if u[:display_exponent] == "0.5"
        base = "<msqrt>#{base}</msqrt>"
      elsif u[:display_exponent]
        exp = "<mn>#{u[:display_exponent]}</mn>".sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
        base = "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
      end
      base
    end

    def mathmlsymbolwrap(units, normalise)
      <<~END
      <math xmlns='#{MATHML_NS}'><mrow>#{mathmlsymbol(units, normalise)}</mrow></math>
      END
    end
  end
end
