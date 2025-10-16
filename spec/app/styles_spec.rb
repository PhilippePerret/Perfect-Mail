
describe "Les styles" do

  it "produit les attributs" do

    src = <<~PMAIL
    styles
      p: color:blue; size:12pt;
      o: color:green; size:10pt;
    section
      p::Ceci est un texte dans le style de p.
      o::Ceci est un autre texte dans le style de o.
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

    actual = PerfectMail::MJML.pmail2mjml(src)
    # puts "actual: \n#{actual}"

    expect(actual.strip).to eq(mjml.strip)
  end

end