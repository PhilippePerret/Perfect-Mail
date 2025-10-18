describe "Parser" do

  PMAIL = PerfectMail::PMAIL
  MJML  = PerfectMail::MJML
  EL = MJML::Element

  it "can deal with fonts" do
    src = <<~PMAIL

    fonts
      Raleway: fonts.googleapis.com/css?family=Raleway
    styles
      n: font:Raleway;size:16pt;
    
    section
      n: Un paragraphe dans le style normal.

    PMAIL
    p = PMAIL.new(src)
    expect(p.fonts).not_to be_nil
    expect(p.fonts.children.count).to eq(1)
    f1 = p.fonts.children[0]
    expect(f1).to be_instance_of(EL::Font)
    expect(f1.name).to eq('Raleway')
    expect(f1.attrs[:href]).to eq('https://fonts.googleapis.com/css?family=Raleway')
    expect(f1.href).to eq('https://fonts.googleapis.com/css?family=Raleway')

  end

  it "can parse two fonts" do
    src = <<~PMAIL
    fonts
      Normal: mon/serif.otf
      Italic: mon/serif-italic.otf
    PMAIL
    p = PMAIL.new(src)
    fs = p.fonts
    expect(fs.children.count).to eq(2)
    f1 = fs.children[0]
    f2 = fs.children[1]
    expect(f1).to be_instance_of(EL::Font)
    expect(f2).to be_instance_of(EL::Font)
    expect(f2.name).to eq('Italic')
    expect(f2.href).to eq('https://mon/serif-italic.otf')
  end

  it "raise error without URL" do
    src = <<~PMAIL
    fonts
      Raleway
      Sans-serif
    PMAIL
    expect { PMAIL.new(src) }.to raise_error(RuntimeError, ERRORS[1000] % ['Raleway'])
  end
end