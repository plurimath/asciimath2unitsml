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
         <mo rspace='thickmathspace'>&#x2062;</mo>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='kg-2'>
           <UnitSystem name='SI' type='SI_base' xml:lang='en-US'/>
           <UnitName xml:lang='en'>kg^-2</UnitName>
           <UnitSymbol type='HTML'>
             kg
             <sup>&#x2212;2</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
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
           </UnitSymbol>
         </Unit>
         <Prefix xmlns='http://unitsml.nist.gov/2005' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
           <PrefixName xml:lang='en'>kilo</PrefixName>
           <PrefixSymbol type='ASCII'>k</PrefixSymbol>
         </Prefix>
         <mo>&#xD7;</mo>
         <mn>9</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='NISTu27'>
           <mi mathvariant='normal'>g</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='NISTu27'>
           <UnitSystem name='SI' type='SI_base' xml:lang='en-US'/>
           <UnitName xml:lang='en'>gram</UnitName>
           <UnitSymbol type='HTML'>g</UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>g</mi>
               </mrow>
             </math>
           </UnitSymbol>
         </Unit>
         <mo>&#xD7;</mo>
         <mn>1</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='kg.s-2'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <UnitName xml:lang='en'>kg*s^-2</UnitName>
           <UnitSymbol type='HTML'>
             kg &#xB7; s
             <sup>&#x2212;2</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
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
           </UnitSymbol>
           <RootUnits>
             <EnumeratedRootUnit unit='gram' prefix='k'/>
             <EnumeratedRootUnit unit='second' powerNumerator='-2'/>
           </RootUnits>
         </Unit>
         <Prefix xmlns='http://unitsml.nist.gov/2005' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
           <PrefixName xml:lang='en'>kilo</PrefixName>
           <PrefixSymbol type='ASCII'>k</PrefixSymbol>
         </Prefix>
         <mo>&#xD7;</mo>
         <mn>812</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='NISTu1.u3e-2_1'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <UnitName xml:lang='en'>meter per second squared</UnitName>
           <UnitSymbol type='HTML'>
             m &#xB7; s
             <sup>&#x2212;2</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
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
           </UnitSymbol>
           <RootUnits>
             <EnumeratedRootUnit unit='meter'/>
             <EnumeratedRootUnit unit='second' powerNumerator='-2'/>
           </RootUnits>
         </Unit>
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
