require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts an AsciiMath string to MathML + UnitsML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    32 + 5 xx 7 "unitsml(kg^-2)" xx 9 "unitsml(g)" xx 1 "unitsml(kg*s^-2)" xx 812 "unitsml(m*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>32</mn>
         <mo>+</mo>
         <mn>5</mn>
         <mo>&#xD7;</mo>
         <mn>7</mn>
         <mrow xref='kg-2'>
           <msup>
             <mrow>
               <mi mathvariant='normal'>kg</mi>
             </mrow>
             <mrow>
               <mo>&#x2212;</mo>
               <mn>2</mn>
             </mrow>
           </msup>
         </mrow>
         <unit xmlns='http://unitsml.nist.gov/2005' xml:id='kg-2'>
           <unitsystem name='SI' type='SI_base' xml:lang='en-US'/>
           <unitname xml:lang='en'>kg^-2</unitname>
           <unitsymbol type='HTML'>
             kg
             <sup>&#x2212;2</sup>
           </unitsymbol>
           <unitsymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>kg</mi>
                   </mrow>
                   <mrow>
                     <mo>&#x2212;</mo>
                     <mn>2</mn>
                   </mrow>
                 </msup>
               </mrow>
             </math>
           </unitsymbol>
         </unit>
         <prefix xmlns='http://unitsml.nist.gov/2005' prefixbase='10' prefixpower='3' xml:id='NISTp10_3'>
           <prefixname xml:lang='en'>kilo</prefixname>
           <prefixsymbol type='ASCII'>k</prefixsymbol>
         </prefix>
         <mo>&#xD7;</mo>
         <mn>9</mn>
         <mrow xref='NISTu27'>
           <mi mathvariant='normal'>g</mi>
         </mrow>
         <unit xmlns='http://unitsml.nist.gov/2005' xml:id='NISTu27'>
           <unitsystem name='SI' type='SI_base' xml:lang='en-US'/>
           <unitname xml:lang='en'>gram</unitname>
           <unitsymbol type='HTML'>g</unitsymbol>
           <unitsymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>g</mi>
               </mrow>
             </math>
           </unitsymbol>
         </unit>
         <mo>&#xD7;</mo>
         <mn>1</mn>
         <mrow xref='kg.s-2'>
           <mi mathvariant='normal'>kg</mi>
           <mo>&#xB7;</mo>
           <msup>
             <mrow>
               <mi mathvariant='normal'>s</mi>
             </mrow>
             <mrow>
               <mo>&#x2212;</mo>
               <mn>2</mn>
             </mrow>
           </msup>
         </mrow>
         <unit xmlns='http://unitsml.nist.gov/2005' xml:id='kg.s-2'>
           <unitsystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <unitname xml:lang='en'>kg*s^-2</unitname>
           <unitsymbol type='HTML'>
             kg &#xB7; s
             <sup>&#x2212;2</sup>
           </unitsymbol>
           <unitsymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>kg</mi>
                 <mo>&#xB7;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>s</mi>
                   </mrow>
                   <mrow>
                     <mo>&#x2212;</mo>
                     <mn>2</mn>
                   </mrow>
                 </msup>
               </mrow>
             </math>
           </unitsymbol>
           <rootunits>
             <enumeratedrootunit unit='gram' prefix='k'/>
             <enumeratedrootunit unit='second' powernumerator='-2'/>
           </rootunits>
         </unit>
         <prefix xmlns='http://unitsml.nist.gov/2005' prefixbase='10' prefixpower='3' xml:id='NISTp10_3'>
           <prefixname xml:lang='en'>kilo</prefixname>
           <prefixsymbol type='ASCII'>k</prefixsymbol>
         </prefix>
         <mo>&#xD7;</mo>
         <mn>812</mn>
         <mrow xref='NISTu1.u3e-2_1'>
           <mi mathvariant='normal'>m</mi>
           <mo>&#xB7;</mo>
           <msup>
             <mrow>
               <mi mathvariant='normal'>s</mi>
             </mrow>
             <mrow>
               <mo>&#x2212;</mo>
               <mn>2</mn>
             </mrow>
           </msup>
         </mrow>
         <unit xmlns='http://unitsml.nist.gov/2005' xml:id='NISTu1.u3e-2_1'>
           <unitsystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <unitname xml:lang='en'>meter per second squared</unitname>
           <unitsymbol type='HTML'>
             m &#xB7; s
             <sup>&#x2212;2</sup>
           </unitsymbol>
           <unitsymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>m</mi>
                 <mo>&#xB7;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>s</mi>
                   </mrow>
                   <mrow>
                     <mo>&#x2212;</mo>
                     <mn>2</mn>
                   </mrow>
                 </msup>
               </mrow>
             </math>
           </unitsymbol>
           <rootunits>
             <enumeratedrootunit unit='meter'/>
             <enumeratedrootunit unit='second' powernumerator='-2'/>
           </rootunits>
         </unit>
       </math>
    OUTPUT
  end

  it "raises error for illegal unit" do
    expect{xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))}.to raise_error(Rsec::SyntaxError)
    12 "unitsml(que?)"
    INPUT
  end

  it "converts MathML + UnitsML to pure MathML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().UnitsML2MathML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
        <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <unitsml xmlns='http://unitsml.nist.gov/2005'>g</unitsml>
</math>
    INPUT
        <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>32</mn>
  <mo>+</mo>
  <mn>5</mn>
  <mo>&#xD7;</mo>
  <mn>7</mn>
  <unitsml xmlns='http://unitsml.nist.gov/2005'>g</unitsml>
</math>
    OUTPUT
  end
end
