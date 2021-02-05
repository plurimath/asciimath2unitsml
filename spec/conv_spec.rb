require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts an AsciiMath string to MathML + UnitsML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    32 + 5 xx 7 "unitsml(kg^-2)" xx 9 "unitsml(g)" xx 1 "unitsml(kg*s^-2)" xx 812 "unitsml(m*s^-2)" - 9 "unitsml(C^3*A)" + 7 "unitsml(hp)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>32</mn>
         <mo>+</mo>
         <mn>5</mn>
         <mo>&#xD7;</mo>
         <mn>7</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_kg-2'>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_kg-2' dimensionURL='#D_M-2'>
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
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_M-2'>
           <Mass symbol='M' powerNumerator='-2'/>
         </Dimension>
         <mo>&#xD7;</mo>
         <mn>9</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_NISTu27'>
           <mi mathvariant='normal'>g</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu27' dimensionURL='#D_M'>
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
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_M'>
           <Mass symbol='M' powerNumerator='1'/>
         </Dimension>
         <mo>&#xD7;</mo>
         <mn>1</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_kg.s-2'>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_kg.s-2' dimensionURL='#D_MT-2'>
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
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_MT-2'>
           <Mass symbol='M' powerNumerator='1'/>
           <Time symbol='T' powerNumerator='-2'/>
         </Dimension>
         <mo>&#xD7;</mo>
         <mn>812</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_NISTu1.u3e-2_1'>
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
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu1.u3e-2_1' dimensionURL='#D_LT-2'>
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
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_LT-2'>
           <Length symbol='L' powerNumerator='1'/>
           <Time symbol='T' powerNumerator='-2'/>
         </Dimension>
         <mo>&#x2212;</mo>
         <mn>9</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_C3.A'>
           <msup>
             <mrow>
               <mi mathvariant='normal'>C</mi>
             </mrow>
             <mrow>
               <mn>3</mn>
             </mrow>
           </msup>
           <mo>&#xB7;</mo>
           <mi mathvariant='normal'>A</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_C3.A' dimensionURL='#D_T3I4'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <UnitName xml:lang='en'>C^3*A</UnitName>
           <UnitSymbol type='HTML'>
             C
             <sup>3</sup>
              &#xB7; A
           </UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>C</mi>
                   </mrow>
                   <mrow>
                     <mn>3</mn>
                   </mrow>
                 </msup>
                 <mo>&#xB7;</mo>
                 <mi mathvariant='normal'>A</mi>
               </mrow>
             </math>
           </UnitSymbol>
           <RootUnits>
             <EnumeratedRootUnit unit='coulomb' powerNumerator='3'/>
             <EnumeratedRootUnit unit='ampere'/>
           </RootUnits>
         </Unit>
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_T3I4'>
           <Time symbol='T' powerNumerator='3'/>
           <ElectricCurrent symbol='I' powerNumerator='4'/>
         </Dimension>
         <mo>+</mo>
         <mn>7</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_NISTu284'>
           <mi mathvariant='normal'>hp</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu284'>
           <UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>
           <UnitName xml:lang='en'>horsepower</UnitName>
           <UnitSymbol type='HTML'>hp</UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>hp</mi>
               </mrow>
             </math>
           </UnitSymbol>
         </Unit>
       </math>
    OUTPUT
  end

  it "raises error for illegal unit" do
    expect{xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))}.to raise_error(Rsec::SyntaxError)
    12 "unitsml(que?)"
    INPUT
  end
end
