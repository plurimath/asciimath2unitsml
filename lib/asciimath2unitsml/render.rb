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

    def htmlsymbol(units, normalise)
      units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:html] : u[:multiplier]
        else
          u[:display_exponent] and exp = "<sup>#{u[:display_exponent].sub(/-/, "&#x2212;")}</sup>"
          base = render(normalise ? @units[u[:unit]].symbolid : u[:unit], :html)
          "#{u[:prefix]}#{base}#{exp}"
        end
      end.join("")
    end

    def mathmlsymbol(units, normalise)
      exp = units.map do |u|
        if u[:multiplier] then u[:multiplier] == "*" ? @multiplier[:mathml] : "<mo>#{u[:multiplier]}</mo>"
        else
          base = render(normalise ? @units[u[:unit]].symbolid : u[:unit], :mathml)
          if u[:prefix]
            base = base.match(/<mi mathvariant='normal'>/) ?
              base.sub(/<mi mathvariant='normal'>/, "<mi mathvariant='normal'>#{u[:prefix]}") :
              "<mrow><mi mathvariant='normal'>#{u[:prefix]}#{base}</mrow>"
          end
          if u[:display_exponent]
            exp = "<mn>#{u[:display_exponent]}</mn>".sub(/<mn>-/, "<mo>&#x2212;</mo><mn>")
            base = "<msup><mrow>#{base}</mrow><mrow>#{exp}</mrow></msup>"
          end
          base
        end
      end.join("")
    end

    def mathmlsymbolwrap(units, normalise)
      <<~END
      <math xmlns='#{MATHML_NS}'><mrow>#{mathmlsymbol(units, normalise)}</mrow></math>
      END
    end
  end
end
