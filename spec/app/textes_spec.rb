describe "Les textes " do

  MJML = PerfectMail::MJML
  PMAIL = PerfectMail::PMAIL

  def compare(src, dst)
    dst = dst.gsub(/^\s+/,'').strip
    unless dst.match?('<mj-body')
      dst = "<mj-body>\n" + dst + "\n</mj-body>"
    end
    unless dst.start_with?('<mjml>')
      dst = "<mjml>\n#{dst}\n</mjml>"
    end
    dst = dst.strip
    actual = MJML.pmail2mjml(src).strip
    puts "ACTUAL:\n#{actual}"
    if actual != dst
      puts "Code MJML différents. Résultat du parsing :".red
      puts PMAIL.new(src).root.inspect.red
    end
    expect(actual).to eq(dst)
  end

  it "peuvent être sur une seule ligne, introduits par 'txt'" do

    src = <<~CODE
    section
      txt: Un premier paragraphe sans style, donc de style normal.
    CODE
    
    dst = <<~CODE
    <mjml>
    <mj-body>
      <mj-section>
        <mj-column>
          <mj-text>Un premier paragraphe sans style, donc de style normal.</mj-text>
        </mj-column>
      </mj-section>
    </mj-body>
    </mjml>
    CODE

    compare(src, dst)
  end

  it 'peuvent être sur plusieurs lignes' do
    src = <<~CODE
    section
      Un texte sur plusieurs lignes. La première.
      Là, il y a la *deuxième*.
      Et là **une** troisième **aussi**.
    CODE
    dst = <<~CODE
    <mj-section>
      <mj-column>
        <mj-text>Un texte sur plusieurs lignes. La première.</mj-text>
        <mj-text>Là, il y a la <em>deuxième</em>.</mj-text>
        <mj-text>Et là <strong>une</strong> troisième <strong>aussi</strong>.</mj-text>
      </mj-column>
    </mj-section>
    CODE
    compare(src, dst)
  end


  it "peuvent être sur plusieurs lignes sur plusieurs colonnes" do
    src = <<~PMAIL

    section
      column
        Un texte colonne 1.
      column
        Un texte colonne 2.
    section
      Un texte toute colonne.
    section
      column
        Sur colonne 1.
      column
        Sur colonne 2.
      column
        Sur colonne 3.
    PMAIL

    dst = <<~MJML
    <mj-section>
      <mj-column>
        <mj-text>Un texte colonne 1.</mj-text>
      </mj-column>
      <mj-column>
        <mj-text>Un texte colonne 2.</mj-text>
      </mj-column>
    </mj-section>

    <mj-section>
      <mj-column>
        <mj-text>Un texte toute colonne.</mj-text>
      </mj-column>
    </mj-section>

    <mj-section>
      <mj-column>
        <mj-text>Sur colonne 1.</mj-text>
      </mj-column>
      <mj-column>
        <mj-text>Sur colonne 2.</mj-text>
      </mj-column>
      <mj-column>
        <mj-text>Sur colonne 3.</mj-text>
      </mj-column>
    </mj-section>
    MJML

    compare(src, dst)

  end
    

end