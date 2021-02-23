require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts an AsciiMath string to MathML + UnitsML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    1 "unitsml(kg*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
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
             kg&#xB7;s
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
       </math>
    OUTPUT
  end

  it "deals with kg and g" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    1 "unitsml(kg)" + 1 "unitsml(g)"
    INPUT
       <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>1</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_NISTu2'>
           <mi mathvariant='normal'>kg</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu2' dimensionURL='#D_M'>
           <UnitSystem name='SI' type='SI_base' xml:lang='en-US'/>
           <UnitName xml:lang='en'>kilogram</UnitName>
           <UnitSymbol type='HTML'>kg</UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>kg</mi>
               </mrow>
             </math>
           </UnitSymbol>
         </Unit>
         <Prefix xmlns='http://unitsml.nist.gov/2005' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
           <PrefixName xml:lang='en'>kilo</PrefixName>
           <PrefixSymbol type='ASCII'>k</PrefixSymbol>
         </Prefix>
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_M'>
           <Mass symbol='M' powerNumerator='1'/>
         </Dimension>
         <mo>+</mo>
         <mn>1</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_NISTu27'>
           <mi mathvariant='normal'>g</mi>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu27' dimensionURL='#D_M'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
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
       </math>
    OUTPUT
  end

  it "deals with non-metric" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    1 "unitsml(hp)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>1</mn>
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

  it "deals with duplicate units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    1 "unitsml(kg*s^-2)" xx 9 "unitsml(kg*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
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
             kg&#xB7;s
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
         <mn>9</mn>
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
             kg&#xB7;s
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
       </math>
    OUTPUT
  end

  it "deals with notational variants" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    9 "unitsml(degK)" + 10 "unitsml(K)"
INPUT
<math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>9</mn>
  <mo rspace='thickmathspace'>&#x2062;</mo>
  <mrow xref='U_NISTu5'>
    <mi mathvariant='normal'>&#xB0;K</mi>
  </mrow>
  <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu5' dimensionURL='#D_Theta'>
    <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
    <UnitName xml:lang='en'>kelvin</UnitName>
    <UnitSymbol type='HTML'>K</UnitSymbol>
    <UnitSymbol type='MathML'>
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow>
          <mi mathvariant='normal'>K</mi>
        </mrow>
      </math>
    </UnitSymbol>
  </Unit>
  <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_Theta'>
    <ThermodynamicTemperature symbol='Theta' powerNumerator='1'/>
  </Dimension>
  <mo>+</mo>
  <mn>10</mn>
  <mo rspace='thickmathspace'>&#x2062;</mo>
  <mrow xref='U_NISTu5'>
    <mi mathvariant='normal'>K</mi>
  </mrow>
  <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_NISTu5' dimensionURL='#D_Theta'>
    <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
    <UnitName xml:lang='en'>kelvin</UnitName>
    <UnitSymbol type='HTML'>K</UnitSymbol>
    <UnitSymbol type='MathML'>
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow>
          <mi mathvariant='normal'>K</mi>
        </mrow>
      </math>
    </UnitSymbol>
  </Unit>
  <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_Theta'>
    <ThermodynamicTemperature symbol='Theta' powerNumerator='1'/>
  </Dimension>
</math>
OUTPUT
  end

  it "deals with units division" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
    9 "unitsml(A*C^3)" + 13 "unitsml(A/C^-3)"
INPUT
<math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>9</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_A.C3'>
           <mi mathvariant='normal'>A</mi>
           <mo>&#xB7;</mo>
           <msup>
             <mrow>
               <mi mathvariant='normal'>C</mi>
             </mrow>
             <mrow>
               <mn>3</mn>
             </mrow>
           </msup>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_A.C3' dimensionURL='#D_M3I4'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <UnitName xml:lang='en'>A*C^3</UnitName>
           <UnitSymbol type='HTML'>
             A&#xB7;C
             <sup>3</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>A</mi>
                 <mo>&#xB7;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>C</mi>
                   </mrow>
                   <mrow>
                     <mn>3</mn>
                   </mrow>
                 </msup>
               </mrow>
             </math>
           </UnitSymbol>
           <RootUnits>
             <EnumeratedRootUnit unit='ampere'/>
             <EnumeratedRootUnit unit='coulomb' powerNumerator='3'/>
           </RootUnits>
         </Unit>
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_M3I4'>
           <Mass symbol='M' powerNumerator='3'/>
           <ElectricCurrent symbol='I' powerNumerator='4'/>
         </Dimension>
         <mo>+</mo>
         <mn>13</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_A/C-3'>
           <mi mathvariant='normal'>A</mi>
           <mo>/</mo>
           <msup>
             <mrow>
               <mi mathvariant='normal'>C</mi>
             </mrow>
             <mrow>
               <mo>&#x2212;</mo>
               <mn>3</mn>
             </mrow>
           </msup>
         </mrow>
         <Unit xmlns='http://unitsml.nist.gov/2005' xml:id='U_A.C3' dimensionURL='#D_M3I4'>
           <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
           <UnitName xml:lang='en'>A*C^3</UnitName>
           <UnitSymbol type='HTML'>
             A&#xB7;C
             <sup>3</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>A</mi>
                 <mo>&#xB7;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>C</mi>
                   </mrow>
                   <mrow>
                     <mn>3</mn>
                   </mrow>
                 </msup>
               </mrow>
             </math>
           </UnitSymbol>
           <RootUnits>
             <EnumeratedRootUnit unit='ampere'/>
             <EnumeratedRootUnit unit='coulomb' powerNumerator='3'/>
           </RootUnits>
         </Unit>
         <Dimension xmlns='http://unitsml.nist.gov/2005' xml:id='D_M3I4'>
           <Mass symbol='M' powerNumerator='3'/>
           <ElectricCurrent symbol='I' powerNumerator='4'/>
         </Dimension>
       </math>
OUTPUT
  end

  it "converts MathML to MatML + UnitsML" do
    input = <<~INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>32</mn>
         <mo>+</mo>
         <mn>5</mn>
         <mo>&#xD7;</mo>
         <mn>7</mn>
         <mtext>unitsml(kg^-2)</mtext>
</math>
    INPUT
    output = <<~OUTPUT
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
</math>
OUTPUT
    expect(xmlpp(Asciimath2UnitsML::Conv.new().MathML2UnitsML(input).to_xml)).to be_equivalent_to xmlpp(output)
    expect(xmlpp(Asciimath2UnitsML::Conv.new().MathML2UnitsML(Nokogiri::XML(input)).to_xml)).to be_equivalent_to xmlpp(output)
  end

  it "raises error for illegal unit" do
    expect{xmlpp(Asciimath2UnitsML::Conv.new().Asciimath2UnitsML(<<~INPUT))}.to raise_error(Rsec::SyntaxError)
    12 "unitsml(que?)"
    INPUT
  end

  it "initialises multiplier" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new(multiplier: "\u00d7").Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
1 "unitsml(kg*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>1</mn>
  <mo rspace='thickmathspace'>&#x2062;</mo>
  <mrow xref='U_kg.s-2'>
    <mi mathvariant='normal'>kg</mi>
    <mo>&#xD7;</mo>
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
      kg&#xD7;s
      <sup>&#x2212;2</sup>
    </UnitSymbol>
    <UnitSymbol type='MathML'>
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow>
          <mi mathvariant='normal'>kg</mi>
          <mo>&#xD7;</mo>
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
</math>
    OUTPUT
    expect(xmlpp(Asciimath2UnitsML::Conv.new(multiplier: :space).Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
1 "unitsml(kg*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
         <mn>1</mn>
         <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='U_kg.s-2'>
           <mi mathvariant='normal'>kg</mi>
           <mo rspace='thickmathspace'>&#x2062;</mo>
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
             kg&#xA0;s
             <sup>&#x2212;2</sup>
           </UnitSymbol>
           <UnitSymbol type='MathML'>
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mrow>
                 <mi mathvariant='normal'>kg</mi>
                 <mo rspace='thickmathspace'>&#x2062;</mo>
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
       </math>
    OUTPUT
    expect(xmlpp(Asciimath2UnitsML::Conv.new(multiplier: :nospace).Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
1 "unitsml(kg*s^-2)"
    INPUT
    <math xmlns='http://www.w3.org/1998/Math/MathML'>
  <mn>1</mn>
  <mo rspace='thickmathspace'>&#x2062;</mo>
  <mrow xref='U_kg.s-2'>
    <mi mathvariant='normal'>kg</mi>
    <mo>&#x2062;</mo>
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
      kgs
      <sup>&#x2212;2</sup>
    </UnitSymbol>
    <UnitSymbol type='MathML'>
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow>
          <mi mathvariant='normal'>kg</mi>
          <mo>&#x2062;</mo>
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
</math>
    OUTPUT
  end
end
