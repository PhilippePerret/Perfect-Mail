
describe "The parser" do

  MJML = PerfectMail::MJML
  PMAIL = PerfectMail::PMAIL
  EL = PerfectMail::MJML::Element

  it "parse one style" do
    src = <<~PMAIL
    styles
      p: color:blue
    PMAIL

    r = PMAIL.new(src).root
    expect(r[:styles]).not_to be_nil
    styles = r[:styles]
    expect(styles.children.count).to eq(1)
    s1 = styles.children.first
    expect(s1).to be_instance_of(EL::Style)
  end

  it "parse several styles" do 
    src = <<~PMAIL
    styles
      p: color:blue
      o: size: 12pt; color: red;
    PMAIL

    r = PMAIL.new(src).root
    expect(r[:styles]).not_to be_nil
    styles = r[:styles]
    expect(styles.children.count).to eq(2)
    s1 = styles.children[0]
    s2 = styles.children[1]
    expect(s1).to be_instance_of(EL::Style)
    expect(s2).to be_instance_of(EL::Style)
  end

  it "substitute short properties" do
  end

  it "produce head and attributes" do

    src = <<~PMAIL
    styles
      p: color:blue; size:12pt;
      o: color:green; size:10pt;
    section
      p:Ceci est un texte dans le style de p.
      o:Ceci est un autre texte dans le style de o.
    PMAIL

    mjml = <<~MJML.gsub(/^\s+/,'')
    <mjml>
      <mj-head>
        <mj-attributes>
          <mj-class name="p" color="blue" font-size="12pt" />
          <mj-class name="o" color="green" font-size="10pt" />
        </mj-attributes>
      </mj-head>
      <mj-body>
        <mj-section>
          <mj-column>
            <mj-text mj-class="p">Ceci est un texte dans le style de p.</mj-text>
            <mj-text mj-class="o">Ceci est un autre texte dans le style de o.</mj-text>
          </mj-column>
        </mj-section>
      </mj-body>
    </mjml>
    MJML

    actual = MJML.pmail2mjml(src)
    # puts "actual: \n#{actual}"

    expect(actual.strip).to eq(mjml.strip)
  end

end