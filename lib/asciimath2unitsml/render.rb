module Asciimath2UnitsML
  class Conv
    def multiplier(val)
      case val
      when :space
        { html: "&#xA0;", mathml: "<mo rspace='thickmathspace'>&#x2062;</mo>" }
      when :nospace
        { html: "", mathml: "<mo>&#x2062;</mo>" }
      else
        { html: HTMLEntities.new.encode(val),
          mathml: "<mo>#{HTMLEntities.new.encode(val)}</mo>" }
      end
    end

    def render(unit, style)
      @symbols[unit][style] || unit
    end

    def htmlent(xml)
      HTMLEntities.new.decode(xml).split(/([<>&])/).map do |c|
        /[<>'"]/.match?(c) ? c : HTMLEntities.new.encode(c, :hexadecimal)
      end.join
    end

    def htmlsymbol(units, normalise)
      units.map do |u|
        if u[:multiplier]
          u[:multiplier] == "*" ? @multiplier[:html] : u[:multiplier]
        elsif u[:unit].nil? && u[:prefix]
          @prefixes[u[:prefix]].html
        else
          base = (u[:prefix] || "") +
            render(normalise ? @units[u[:unit]].symbolid : u[:unit], :html)
          htmlsymbol_exponent(u, base)
        end
      end.join
    end

    def htmlsymbol_exponent(unit, base)
      if unit[:display_exponent] == "0.5"
        base = "&#x221a;#{base}"
      elsif unit[:display_exponent]
        exp = "<sup>#{unit[:display_exponent].sub(/-/, '&#x2212;')}</sup>"
        base += exp
      end
      base
    end

    def mathmlsymbol(units, normalise, multiplier = nil)
      multiplier = multiplier ? "<mo>#{multiplier}</mo>" : @multiplier[:mathml]
      units.map do |u|
        if u[:multiplier]
          u[:multiplier] == "*" ? multiplier : "<mo>#{u[:multiplier]}</mo>"
        elsif u[:unit].nil? && u[:prefix]
          %(<mi mathvariant='normal'>#{htmlent(@prefixes[u[:prefix]].html)}</mi>)
        else
          mathmlsymbol1(u, normalise)
        end
      end.join
    end

    def mathmlsymbol1(unit, normalise)
      base = if unit[:dim]
               render(normalise ? @dimensions[unit[:dim]].symbolid : unit[:dim],
                      :mathml)
             else
               render(normalise ? @units[unit[:unit]].symbolid : unit[:unit],
                      :mathml)
             end
      unit[:prefix] and base = mathmlsymbol1_prefixed(unit, base)
      mathmlsymbol_exponent(unit, base)
    end

    def mathmlsymbol1_prefixed(unit, base)
      prefix = htmlent(@prefixes[unit[:prefix]].html)
      if /<mi mathvariant='normal'>/.match?(base)
        base.sub(/<mi mathvariant='normal'>/,
                 "<mi mathvariant='normal'>#{prefix}")
      else
        "<mrow><mi mathvariant='normal'>#{prefix}#{base}</mrow>"
      end
    end

    def mathmlsymbol_exponent(unit, base)
      if unit[:display_exponent] == "0.5"
        base = "<msqrt>#{base}</msqrt>"
      elsif unit[:display_exponent]
        exp = "<mn>#{unit[:display_exponent]}</mn>"
          .sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
        base = "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
      end
      base
    end

    def mathmlsymbolwrap(units, normalise)
      <<~XML
        <math xmlns='#{MATHML_NS}'><mrow>#{mathmlsymbol(units, normalise)}</mrow></math>
      XML
    end
  end
end
