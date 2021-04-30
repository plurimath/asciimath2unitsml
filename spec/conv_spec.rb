require "spec_helper"

RSpec.describe Asciimath2UnitsML do
  it "converts an AsciiMath string to MathML + UnitsML" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(mm*s^-2)"
    INPUT
      <?xml version='1.0'?>
         <math xmlns='http://www.w3.org/1998/Math/MathML'>
           <mn>1</mn>
           <mo rspace='thickmathspace'>&#x2062;</mo>
           <mrow xref='U_mm.s-2'>
             <mi mathvariant='normal'>mm</mi>
             <mo>&#x22C5;</mo>
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
           <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_mm.s-2' dimensionURL='#NISTd28'>
             <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
             <UnitName xml:lang='en'>mm*s^-2</UnitName>
             <UnitSymbol type='HTML'>
               mm&#x22C5;s
               <sup>&#x2212;2</sup>
             </UnitSymbol>
             <UnitSymbol type='MathML'>
               <math xmlns='http://www.w3.org/1998/Math/MathML'>
                 <mrow>
                   <mi mathvariant='normal'>mm</mi>
                   <mo>&#x22C5;</mo>
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
               <EnumeratedRootUnit unit='meter' prefix='m'/>
               <EnumeratedRootUnit unit='second' powerNumerator='-2'/>
             </RootUnits>
           </Unit>
           <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-3' xml:id='NISTp10_-3'>
             <PrefixName xml:lang='en'>milli</PrefixName>
             <PrefixSymbol type='ASCII'>m</PrefixSymbol>
             <PrefixSymbol type='unicode'>m</PrefixSymbol>
             <PrefixSymbol type='LaTeX'>m</PrefixSymbol>
             <PrefixSymbol type='HTML'>m</PrefixSymbol>
           </Prefix>
           <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd28'>
             <Length symbol='L' powerNumerator='1'/>
             <Time symbol='T' powerNumerator='-2'/>
           </Dimension>
         </math>
    OUTPUT
  end

  it "deals with non-Ascii units and prefixes" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(um)"
    INPUT
          <?xml version='1.0'?>
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>1</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_um'>
          <mi mathvariant='normal'>&#xB5;m</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_um' dimensionURL='#NISTd1'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>um</UnitName>
          <UnitSymbol type='HTML'>um</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>&#xB5;m</mi>
              </mrow>
            </math>
          </UnitSymbol>
          <RootUnits>
        <EnumeratedRootUnit unit='meter' prefix='u'/>
      </RootUnits>
        </Unit>
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-6' xml:id='NISTp10_-6'>
          <PrefixName xml:lang='en'>micro</PrefixName>
          <PrefixSymbol type='ASCII'>u</PrefixSymbol>
          <PrefixSymbol type='unicode'>&#x3BC;</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>$mu$</PrefixSymbol>
          <PrefixSymbol type='HTML'>&#xB5;</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd1'>
          <Length symbol='L' powerNumerator='1'/>
        </Dimension>
      </math>
    OUTPUT
  end

  it "does not insert space before non-alphabetic units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(degK)" + 1 "unitsml(prime)" + ii(theta) = s//r "unitsml(rad)" + 10^(12) "unitsml(Hz)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>1</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu5'>
          <mi mathvariant='normal'>&#xB0;K</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu5' dimensionURL='#NISTd5'>
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
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd5'>
          <ThermodynamicTemperature symbol='Theta' powerNumerator='1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq5' dimensionURL='#NISTd5' quantityType='base'>
          <QuantityName xml:lang='en-US'>thermodynamic temperature</QuantityName>
        </Quantity>
        <mo>+</mo>
        <mn>1</mn>
        <mo>&#x2062;</mo>
        <mrow xref='U_NISTu147'>
          <mi mathvariant='normal'>&#x2032;</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu147'>
          <UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>
          <UnitName xml:lang='en'>minute (minute of arc)</UnitName>
          <UnitSymbol type='HTML'>&#x2032;</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>&#x2032;</mi>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd9'>
          <PlaneAngle symbol='Phi' powerNumerator='1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq9' dimensionURL='#NISTd9' quantityType='base'>
          <QuantityName xml:lang='en-US'>plane angle</QuantityName>
          <QuantityName xml:lang='en-US'>angle</QuantityName>
        </Quantity>
        <mo>+</mo>
        <mstyle mathvariant='italic'>
          <mi>&#x3B8;</mi>
        </mstyle>
        <mo>=</mo>
        <mi>s</mi>
        <mo>/</mo>
        <mi>r</mi>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu9'>
          <mi mathvariant='normal'>rad</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu9' dimensionURL='#D_L0'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>radian</UnitName>
          <UnitSymbol type='HTML'>rad</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>rad</mi>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_L0'>
          <Length symbol='L' powerNumerator='0'/>
        </Dimension>
        <mo>+</mo>
        <msup>
          <mrow>
            <mn>10</mn>
          </mrow>
          <mrow>
            <mn>12</mn>
          </mrow>
        </msup>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu31'>
          <mi mathvariant='normal'>Hz</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu31' dimensionURL='#NISTd24'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>hertz</UnitName>
          <UnitSymbol type='HTML'>Hz</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>Hz</mi>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd24'>
          <Time symbol='T' powerNumerator='-1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq45' dimensionURL='#NISTd24' quantityType='base'>
          <QuantityName xml:lang='en-US'>frequency</QuantityName>
        </Quantity>
      </math>
    OUTPUT
  end

  it "does not insert space before operators" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      8 "unitsml(kg)" cdot "unitsml(m)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>8</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_NISTu2'>
                 <mi mathvariant='normal'>kg</mi>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu2' dimensionURL='#NISTd2'>
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
                 <RootUnits>
                   <EnumeratedRootUnit unit='gram' prefix='k'/>
                 </RootUnits>
               </Unit>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
                 <PrefixName xml:lang='en'>kilo</PrefixName>
                 <PrefixSymbol type='ASCII'>k</PrefixSymbol>
                 <PrefixSymbol type='unicode'>k</PrefixSymbol>
                 <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
                 <PrefixSymbol type='HTML'>k</PrefixSymbol>
               </Prefix>
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd2'>
                 <Mass symbol='M' powerNumerator='1'/>
               </Dimension>
               <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq2' dimensionURL='#NISTd2' quantityType='base'>
                 <QuantityName xml:lang='en-US'>mass</QuantityName>
               </Quantity>
               <mo>&#x22C5;</mo>
               <mrow xref='U_NISTu1'>
                 <mi mathvariant='normal'>m</mi>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu1' dimensionURL='#NISTd1'>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>meter</UnitName>
                 <UnitSymbol type='HTML'>m</UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <mi mathvariant='normal'>m</mi>
                     </mrow>
                   </math>
                 </UnitSymbol>
               </Unit>
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd1'>
                 <Length symbol='L' powerNumerator='1'/>
               </Dimension>
             </math>
    OUTPUT
  end

  it "deals with sqrt units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(sqrt(Hz))"
    INPUT
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>1</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_sqrtHz'>
          <msqrt>
            <mi mathvariant='normal'>Hz</mi>
          </msqrt>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_Hz0.5' dimensionURL='#D_T-0.5'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>Hz^0.5</UnitName>
          <UnitSymbol type='HTML'>&#x221A;Hz</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <msqrt>
                  <mi mathvariant='normal'>Hz</mi>
                </msqrt>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_T-0.5'>
          <Time symbol='T' powerNumerator='-0.5'/>
        </Dimension>
      </math>
    OUTPUT
  end

  it "deals with kg and g" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(kg)" + 1 "unitsml(g)"
    INPUT
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>1</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_NISTu2'>
                 <mi mathvariant='normal'>kg</mi>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu2' dimensionURL='#NISTd2'>
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
                 <RootUnits>
        <EnumeratedRootUnit unit='gram' prefix='k'/>
      </RootUnits>
               </Unit>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
                 <PrefixName xml:lang='en'>kilo</PrefixName>
                 <PrefixSymbol type='ASCII'>k</PrefixSymbol>
          <PrefixSymbol type='unicode'>k</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
          <PrefixSymbol type='HTML'>k</PrefixSymbol>
               </Prefix>
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd2'>
                 <Mass symbol='M' powerNumerator='1'/>
               </Dimension>
               <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq2' dimensionURL='#NISTd2' quantityType='base'>
        <QuantityName xml:lang='en-US'>mass</QuantityName>
      </Quantity>
               <mo>+</mo>
               <mn>1</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_NISTu27'>
                 <mi mathvariant='normal'>g</mi>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu27' dimensionURL='#NISTd2'>
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
             </math>
    OUTPUT
  end

  it "deals with non-metric" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(hp)"
    INPUT
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>1</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_NISTu284'>
                 <mi mathvariant='normal'>hp</mi>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu284'>
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
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd16'>
        <Length symbol='L' powerNumerator='2'/>
        <Mass symbol='M' powerNumerator='1'/>
        <Time symbol='T' powerNumerator='-3'/>
      </Dimension>
      <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq20' dimensionURL='#NISTd16' quantityType='base'>
        <QuantityName xml:lang='en-US'>power</QuantityName>
      </Quantity>
             </math>
    OUTPUT
  end

  it "deals with duplicate units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      1 "unitsml(kg*s^-2)" xx 9 "unitsml(kg*s^-2)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
           <mn>1</mn>
           <mo rspace='thickmathspace'>&#x2062;</mo>
           <mrow xref='U_kg.s-2'>
             <mi mathvariant='normal'>kg</mi>
             <mo>&#x22C5;</mo>
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
           <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_kg.s-2' dimensionURL='#NISTd37'>
             <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
             <UnitName xml:lang='en'>kg*s^-2</UnitName>
             <UnitSymbol type='HTML'>
               kg&#x22C5;s
               <sup>&#x2212;2</sup>
             </UnitSymbol>
             <UnitSymbol type='MathML'>
               <math xmlns='http://www.w3.org/1998/Math/MathML'>
                 <mrow>
                   <mi mathvariant='normal'>kg</mi>
                   <mo>&#x22C5;</mo>
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
           <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
             <PrefixName xml:lang='en'>kilo</PrefixName>
             <PrefixSymbol type='ASCII'>k</PrefixSymbol>
      <PrefixSymbol type='unicode'>k</PrefixSymbol>
      <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
      <PrefixSymbol type='HTML'>k</PrefixSymbol>
           </Prefix>
           <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd37'>
             <Mass symbol='M' powerNumerator='1'/>
             <Time symbol='T' powerNumerator='-2'/>
           </Dimension>
           <mo>&#xD7;</mo>
           <mn>9</mn>
           <mo rspace='thickmathspace'>&#x2062;</mo>
           <mrow xref='U_kg.s-2'>
             <mi mathvariant='normal'>kg</mi>
             <mo>&#x22C5;</mo>
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
    OUTPUT
  end

  it "deals with parentheses" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      10 "unitsml(K/(kg*m))"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
          <mn>10</mn>
          <mo rspace='thickmathspace'>&#x2062;</mo>
          <mrow xref='U_K/kg.m'>
            <mi mathvariant='normal'>K</mi>
            <mo>/</mo>
            <mi mathvariant='normal'>kg</mi>
            <mo>&#x22C5;</mo>
            <mi mathvariant='normal'>m</mi>
          </mrow>
          <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_K.kg-1.m-1' dimensionURL='#D_L-1M-1Theta'>
            <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
            <UnitName xml:lang='en'>K*kg^-1*m^-1</UnitName>
            <UnitSymbol type='HTML'>
              K&#x22C5;kg
              <sup>&#x2212;1</sup>
              &#x22C5;m
              <sup>&#x2212;1</sup>
            </UnitSymbol>
            <UnitSymbol type='MathML'>
              <math xmlns='http://www.w3.org/1998/Math/MathML'>
                <mrow>
                  <mi mathvariant='normal'>K</mi>
                  <mo>&#x22C5;</mo>
                  <msup>
                    <mrow>
                      <mi mathvariant='normal'>kg</mi>
                    </mrow>
                    <mrow>
                      <mo>&#x2212;</mo>
                      <mn>1</mn>
                    </mrow>
                  </msup>
                  <mo>&#x22C5;</mo>
                  <msup>
                    <mrow>
                      <mi mathvariant='normal'>m</mi>
                    </mrow>
                    <mrow>
                      <mo>&#x2212;</mo>
                      <mn>1</mn>
                    </mrow>
                  </msup>
                </mrow>
              </math>
            </UnitSymbol>
            <RootUnits>
              <EnumeratedRootUnit unit='kelvin'/>
              <EnumeratedRootUnit unit='gram' prefix='k' powerNumerator='-1'/>
              <EnumeratedRootUnit unit='meter' powerNumerator='-1'/>
            </RootUnits>
          </Unit>
          <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
            <PrefixName xml:lang='en'>kilo</PrefixName>
            <PrefixSymbol type='ASCII'>k</PrefixSymbol>
            <PrefixSymbol type='unicode'>k</PrefixSymbol>
            <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
            <PrefixSymbol type='HTML'>k</PrefixSymbol>
          </Prefix>
          <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_L-1M-1Theta'>
            <Length symbol='L' powerNumerator='-1'/>
            <Mass symbol='M' powerNumerator='-1'/>
            <ThermodynamicTemperature symbol='Theta' powerNumerator='1'/>
          </Dimension>
        </math>
    OUTPUT
  end

  it "deals with notational variants" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(degK)" + 10 "unitsml(K)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>9</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu5'>
          <mi mathvariant='normal'>&#xB0;K</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu5' dimensionURL='#NISTd5'>
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
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd5'>
          <ThermodynamicTemperature symbol='Theta' powerNumerator='1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq5' dimensionURL='#NISTd5' quantityType='base'>
        <QuantityName xml:lang='en-US'>thermodynamic temperature</QuantityName>
      </Quantity>
        <mo>+</mo>
        <mn>10</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu5'>
          <mi mathvariant='normal'>K</mi>
        </mrow>
      </math>
    OUTPUT
  end

  it "deals with prefixed units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(mbar)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>9</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu362'>
          <mi mathvariant='normal'>mbar</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu362'>
          <UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>
          <UnitName xml:lang='en'>millibar</UnitName>
          <UnitSymbol type='HTML'>mbar</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>mbar</mi>
              </mrow>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit='bar' prefix='m'/>
          </RootUnits>
        </Unit>
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-3' xml:id='NISTp10_-3'>
          <PrefixName xml:lang='en'>milli</PrefixName>
          <PrefixSymbol type='ASCII'>m</PrefixSymbol>
          <PrefixSymbol type='unicode'>m</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>m</PrefixSymbol>
          <PrefixSymbol type='HTML'>m</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd14'>
        <Length symbol='L' powerNumerator='-1'/>
        <Mass symbol='M' powerNumerator='1'/>
        <Time symbol='T' powerNumerator='-2'/>
      </Dimension>
      </math>
    OUTPUT
  end

  it "deals with standalone prefixes" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      "unitsml(p-)" "unitsml(da-)"
    INPUT
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow xref='NISTp10_-12'>
          <mi mathvariant='normal'>p</mi>
        </mrow>
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-12' xml:id='NISTp10_-12'>
          <PrefixName xml:lang='en'>pico</PrefixName>
          <PrefixSymbol type='ASCII'>p</PrefixSymbol>
          <PrefixSymbol type='unicode'>p</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>p</PrefixSymbol>
          <PrefixSymbol type='HTML'>p</PrefixSymbol>
        </Prefix>
        <mo rspace='thickmathspace'>&#x2062;</mo>
         <mrow xref='NISTp10_1'>
         <mi mathvariant='normal'>da</mi>
       </mrow>
       <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='1' xml:id='NISTp10_1'>
         <PrefixName xml:lang='en'>deka</PrefixName>
         <PrefixSymbol type='ASCII'>da</PrefixSymbol>
         <PrefixSymbol type='unicode'>da</PrefixSymbol>
         <PrefixSymbol type='LaTeX'>da</PrefixSymbol>
         <PrefixSymbol type='HTML'>da</PrefixSymbol>
       </Prefix>
      </math>
    OUTPUT
  end

  it "deals with HTML entities in UnitsDB" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      "unitsml(u-)" + "unitsml(um)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mrow xref='NISTp10_-6'>
          <mi mathvariant='normal'>&#xB5;</mi>
        </mrow>
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-6' xml:id='NISTp10_-6'>
          <PrefixName xml:lang='en'>micro</PrefixName>
          <PrefixSymbol type='ASCII'>u</PrefixSymbol>
          <PrefixSymbol type='unicode'>&#x3BC;</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>$mu$</PrefixSymbol>
          <PrefixSymbol type='HTML'>&#xB5;</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd2'>
          <Mass symbol='M' powerNumerator='1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq2' dimensionURL='#NISTd2' quantityType='base'>
          <QuantityName xml:lang='en-US'>mass</QuantityName>
        </Quantity>
        <mo>+</mo>
        <mrow xref='U_um'>
          <mi mathvariant='normal'>&#xB5;m</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_um' dimensionURL='#NISTd1'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>um</UnitName>
          <UnitSymbol type='HTML'>um</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>&#xB5;m</mi>
              </mrow>
            </math>
          </UnitSymbol>
          <RootUnits>
            <EnumeratedRootUnit unit='meter' prefix='u'/>
          </RootUnits>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd1'>
          <Length symbol='L' powerNumerator='1'/>
        </Dimension>
      </math>
    OUTPUT
  end

  it "deals with units division" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(A*C^3)" + 13 "unitsml(A/C^-3)" + 2 "unitsml(J/kg*K)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>9</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_A.C3'>
                 <mi mathvariant='normal'>A</mi>
                 <mo>&#x22C5;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>C</mi>
                   </mrow>
                   <mrow>
                     <mn>3</mn>
                   </mrow>
                 </msup>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_A.C3' dimensionURL='#D_M3I4'>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>A*C^3</UnitName>
                 <UnitSymbol type='HTML'>
                   A&#x22C5;C
                   <sup>3</sup>
                 </UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <mi mathvariant='normal'>A</mi>
                       <mo>&#x22C5;</mo>
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
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_M3I4'>
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
               <mo>+</mo>
      <mn>2</mn>
      <mo rspace='thickmathspace'>&#x2062;</mo>
      <mrow xref='U_J/kg.K'>
        <mi mathvariant='normal'>J</mi>
        <mo>/</mo>
        <mi mathvariant='normal'>kg</mi>
        <mo>&#x22C5;</mo>
        <mi mathvariant='normal'>K</mi>
      </mrow>
      <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu13.u27p10_3e-1/1.u5e-1/1' dimensionURL='#D_L2M0T-2Theta-1'>
        <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
        <UnitName xml:lang='en'>joule per kilogram kelvin</UnitName>
        <UnitSymbol type='HTML'>
          J&#x22C5;kg
          <sup>&#x2212;1</sup>
          &#x22C5;K
          <sup>&#x2212;1</sup>
        </UnitSymbol>
        <UnitSymbol type='MathML'>
          <math xmlns='http://www.w3.org/1998/Math/MathML'>
            <mrow>
              <mi mathvariant='normal'>J</mi>
              <mo>&#x22C5;</mo>
              <msup>
                <mrow>
                  <mi mathvariant='normal'>kg</mi>
                </mrow>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>1</mn>
                </mrow>
              </msup>
              <mo>&#x22C5;</mo>
              <msup>
                <mrow>
                  <mi mathvariant='normal'>K</mi>
                </mrow>
                <mrow>
                  <mo>&#x2212;</mo>
                  <mn>1</mn>
                </mrow>
              </msup>
            </mrow>
          </math>
        </UnitSymbol>
        <RootUnits>
          <EnumeratedRootUnit unit='joule'/>
          <EnumeratedRootUnit unit='gram' prefix='k' powerNumerator='-1'/>
          <EnumeratedRootUnit unit='kelvin' powerNumerator='-1'/>
        </RootUnits>
      </Unit>
      <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
        <PrefixName xml:lang='en'>kilo</PrefixName>
        <PrefixSymbol type='ASCII'>k</PrefixSymbol>
        <PrefixSymbol type='unicode'>k</PrefixSymbol>
        <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
        <PrefixSymbol type='HTML'>k</PrefixSymbol>
      </Prefix>
      <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd40'>
        <Length symbol='L' powerNumerator='2'/>
        <Time symbol='T' powerNumerator='-2'/>
        <ThermodynamicTemperature symbol='Theta' powerNumerator='-1'/>
      </Dimension>
      <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_L2M0T-2Theta-1'>
        <Length symbol='L' powerNumerator='2'/>
        <Mass symbol='M' powerNumerator='0'/>
        <Time symbol='T' powerNumerator='-2'/>
        <ThermodynamicTemperature symbol='Theta' powerNumerator='-1'/>
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
                <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_kg-2' dimensionURL='#D_M-2'>
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
         <RootUnits>
        <EnumeratedRootUnit unit='gram' prefix='k' powerNumerator='-2'/>
      </RootUnits>
       </Unit>
       <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
         <PrefixName xml:lang='en'>kilo</PrefixName>
         <PrefixSymbol type='ASCII'>k</PrefixSymbol>
          <PrefixSymbol type='unicode'>k</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
          <PrefixSymbol type='HTML'>k</PrefixSymbol>
       </Prefix>
       <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='D_M-2'>
         <Mass symbol='M' powerNumerator='-2'/>
       </Dimension>
      </math>
    OUTPUT
    expect(xmlpp(Asciimath2UnitsML::Conv.new
      .MathML2UnitsML(input).to_xml)).to be_equivalent_to xmlpp(output)
    expect(xmlpp(Asciimath2UnitsML::Conv.new
      .MathML2UnitsML(Nokogiri::XML(input)).to_xml))
      .to be_equivalent_to xmlpp(output)
  end

  it "raises error for illegal unit" do
    expect { xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT)) }.to raise_error(Rsec::SyntaxError)
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
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_kg.s-2' dimensionURL='#NISTd37'>
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
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
          <PrefixName xml:lang='en'>kilo</PrefixName>
          <PrefixSymbol type='ASCII'>k</PrefixSymbol>
          <PrefixSymbol type='unicode'>k</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
          <PrefixSymbol type='HTML'>k</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd37'>
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
           <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_kg.s-2' dimensionURL='#NISTd37'>
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
           <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
             <PrefixName xml:lang='en'>kilo</PrefixName>
             <PrefixSymbol type='ASCII'>k</PrefixSymbol>
      <PrefixSymbol type='unicode'>k</PrefixSymbol>
      <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
      <PrefixSymbol type='HTML'>k</PrefixSymbol>
           </Prefix>
           <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd37'>
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
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_kg.s-2' dimensionURL='#NISTd37'>
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
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='3' xml:id='NISTp10_3'>
          <PrefixName xml:lang='en'>kilo</PrefixName>
          <PrefixSymbol type='ASCII'>k</PrefixSymbol>
          <PrefixSymbol type='unicode'>k</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>k</PrefixSymbol>
          <PrefixSymbol type='HTML'>k</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd37'>
          <Mass symbol='M' powerNumerator='1'/>
          <Time symbol='T' powerNumerator='-2'/>
        </Dimension>
      </math>
    OUTPUT
  end

  it "deals with dimension decomposition with like units" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(mW*cm^(-2))"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>9</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_mW.cm-2'>
                 <mi mathvariant='normal'>mW</mi>
                 <mo>&#x22C5;</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>cm</mi>
                   </mrow>
                   <mrow>
                     <mo>&#x2212;</mo>
                     <mn>2</mn>
                   </mrow>
                 </msup>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_mW.cm-2'>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>mW*cm^-2</UnitName>
                 <UnitSymbol type='HTML'>
                   mW&#x22C5;cm
                   <sup>&#x2212;2</sup>
                 </UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <mi mathvariant='normal'>mW</mi>
                       <mo>&#x22C5;</mo>
                       <msup>
                         <mrow>
                           <mi mathvariant='normal'>cm</mi>
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
                   <EnumeratedRootUnit unit='watt' prefix='m'/>
                   <EnumeratedRootUnit unit='meter' prefix='c' powerNumerator='-2'/>
                 </RootUnits>
               </Unit>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-3' xml:id='NISTp10_-3'>
                 <PrefixName xml:lang='en'>milli</PrefixName>
                 <PrefixSymbol type='ASCII'>m</PrefixSymbol>
                 <PrefixSymbol type='unicode'>m</PrefixSymbol>
                 <PrefixSymbol type='LaTeX'>m</PrefixSymbol>
                 <PrefixSymbol type='HTML'>m</PrefixSymbol>
               </Prefix>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-2' xml:id='NISTp10_-2'>
                 <PrefixName xml:lang='en'>centi</PrefixName>
                 <PrefixSymbol type='ASCII'>c</PrefixSymbol>
                 <PrefixSymbol type='unicode'>c</PrefixSymbol>
                 <PrefixSymbol type='LaTeX'>c</PrefixSymbol>
                 <PrefixSymbol type='HTML'>c</PrefixSymbol>
               </Prefix>
             </math>
    OUTPUT
  end

  it "deals with quantity input" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(m, quantity: NISTq103)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>9</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_NISTu1'>
          <mi mathvariant='normal'>m</mi>
        </mrow>
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu1' dimensionURL='#NISTd1'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>meter</UnitName>
          <UnitSymbol type='HTML'>m</UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>m</mi>
              </mrow>
            </math>
          </UnitSymbol>
        </Unit>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd1'>
          <Length symbol='L' powerNumerator='1'/>
        </Dimension>
        <Quantity xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTq103' dimensionURL='#NISTd1' quantityType='base'>
          <QuantityName xml:lang='en-US'>position vector</QuantityName>
        </Quantity>
      </math>
    OUTPUT
  end

  it "deals with name input" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(cal_th/cm^2, name: langley)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>9</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_cal_th/cm2'>
                 <msub>
                   <mrow>
                     <mi mathvariant='normal'>cal</mi>
                   </mrow>
                   <mrow>
                     <mi mathvariant='normal'>th</mi>
                   </mrow>
                 </msub>
                 <mo>/</mo>
                 <msup>
                   <mrow>
                     <mi mathvariant='normal'>cm</mi>
                   </mrow>
                   <mrow>
                     <mn>2</mn>
                   </mrow>
                 </msup>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_cal_th.cm-2'>
                 <UnitSystem name='not_SI' type='not_SI' xml:lang='en-US'/>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>langley</UnitName>
                 <UnitSymbol type='HTML'>
                   cal
                   <sub>th</sub>
                   &#x22C5;cm
                   <sup>&#x2212;2</sup>
                 </UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <msub>
                         <mrow>
                           <mi mathvariant='normal'>cal</mi>
                         </mrow>
                         <mrow>
                           <mi mathvariant='normal'>th</mi>
                         </mrow>
                       </msub>
                       <mo>&#x22C5;</mo>
                       <msup>
                         <mrow>
                           <mi mathvariant='normal'>cm</mi>
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
                   <EnumeratedRootUnit unit='thermochemical calorie'/>
                   <EnumeratedRootUnit unit='meter' prefix='c' powerNumerator='-2'/>
                 </RootUnits>
               </Unit>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-2' xml:id='NISTp10_-2'>
                 <PrefixName xml:lang='en'>centi</PrefixName>
                 <PrefixSymbol type='ASCII'>c</PrefixSymbol>
                 <PrefixSymbol type='unicode'>c</PrefixSymbol>
                 <PrefixSymbol type='LaTeX'>c</PrefixSymbol>
                 <PrefixSymbol type='HTML'>c</PrefixSymbol>
               </Prefix>
             </math>
    OUTPUT
  end

  it "deals with symbol input" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      9 "unitsml(m, symbol: La)" + 10 "unitsml(cm*s^-2, symbol: cm cdot s^-2)"
    INPUT
             <math xmlns='http://www.w3.org/1998/Math/MathML'>
               <mn>9</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_NISTu1'>
                 <math>
                   <mi mathvariant='normal'>L</mi>
                   <mi mathvariant='normal'>a</mi>
                 </math>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_NISTu1' dimensionURL='#NISTd1'>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>meter</UnitName>
                 <UnitSymbol type='HTML'>m</UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <mi mathvariant='normal'>m</mi>
                     </mrow>
                   </math>
                 </UnitSymbol>
               </Unit>
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd1'>
                 <Length symbol='L' powerNumerator='1'/>
               </Dimension>
               <mo>+</mo>
               <mn>10</mn>
               <mo rspace='thickmathspace'>&#x2062;</mo>
               <mrow xref='U_cm.s-2'>
                 <math>
                   <mi mathvariant='normal'>c</mi>
                   <mi mathvariant='normal'>m</mi>
                   <mo>&#x22C5;</mo>
                   <msup>
                     <mrow>
                       <mi mathvariant='normal'>s</mi>
                     </mrow>
                     <mrow>
                       <mo>&#x2212;</mo>
                     </mrow>
                   </msup>
                   <mn>2</mn>
                 </math>
               </mrow>
               <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_cm.s-2' dimensionURL='#NISTd28'>
                 <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
                 <UnitName xml:lang='en'>cm*s^-2</UnitName>
                 <UnitSymbol type='HTML'>
                   cm&#x22C5;s
                   <sup>&#x2212;2</sup>
                 </UnitSymbol>
                 <UnitSymbol type='MathML'>
                   <math xmlns='http://www.w3.org/1998/Math/MathML'>
                     <mrow>
                       <mi mathvariant='normal'>cm</mi>
                       <mo>&#x22C5;</mo>
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
                   <EnumeratedRootUnit unit='meter' prefix='c'/>
                   <EnumeratedRootUnit unit='second' powerNumerator='-2'/>
                 </RootUnits>
               </Unit>
               <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-2' xml:id='NISTp10_-2'>
                 <PrefixName xml:lang='en'>centi</PrefixName>
                 <PrefixSymbol type='ASCII'>c</PrefixSymbol>
                 <PrefixSymbol type='unicode'>c</PrefixSymbol>
                 <PrefixSymbol type='LaTeX'>c</PrefixSymbol>
                 <PrefixSymbol type='HTML'>c</PrefixSymbol>
               </Prefix>
               <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd28'>
                 <Length symbol='L' powerNumerator='1'/>
                 <Time symbol='T' powerNumerator='-2'/>
               </Dimension>
             </math>
    OUTPUT
  end

  it "deals with multiplier input" do
    expect(xmlpp(Asciimath2UnitsML::Conv.new.Asciimath2UnitsML(<<~INPUT))).to be_equivalent_to xmlpp(<<~OUTPUT)
      10 "unitsml(cm*s^-2, multiplier: xx)"
    INPUT
      <math xmlns='http://www.w3.org/1998/Math/MathML'>
        <mn>10</mn>
        <mo rspace='thickmathspace'>&#x2062;</mo>
        <mrow xref='U_cm.s-2'>
          <mi mathvariant='normal'>cm</mi>
          <mo>xx</mo>
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
        <Unit xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='U_cm.s-2' dimensionURL='#NISTd28'>
          <UnitSystem name='SI' type='SI_derived' xml:lang='en-US'/>
          <UnitName xml:lang='en'>cm*s^-2</UnitName>
          <UnitSymbol type='HTML'>
            cm&#x22C5;s
            <sup>&#x2212;2</sup>
          </UnitSymbol>
          <UnitSymbol type='MathML'>
            <math xmlns='http://www.w3.org/1998/Math/MathML'>
              <mrow>
                <mi mathvariant='normal'>cm</mi>
                <mo>&#x22C5;</mo>
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
            <EnumeratedRootUnit unit='meter' prefix='c'/>
            <EnumeratedRootUnit unit='second' powerNumerator='-2'/>
          </RootUnits>
        </Unit>
        <Prefix xmlns='https://schema.unitsml.org/unitsml/1.0' prefixBase='10' prefixPower='-2' xml:id='NISTp10_-2'>
          <PrefixName xml:lang='en'>centi</PrefixName>
          <PrefixSymbol type='ASCII'>c</PrefixSymbol>
          <PrefixSymbol type='unicode'>c</PrefixSymbol>
          <PrefixSymbol type='LaTeX'>c</PrefixSymbol>
          <PrefixSymbol type='HTML'>c</PrefixSymbol>
        </Prefix>
        <Dimension xmlns='https://schema.unitsml.org/unitsml/1.0' xml:id='NISTd28'>
          <Length symbol='L' powerNumerator='1'/>
          <Time symbol='T' powerNumerator='-2'/>
        </Dimension>
      </math>
    OUTPUT
  end
end
