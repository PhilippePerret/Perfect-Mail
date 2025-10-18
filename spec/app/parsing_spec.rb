describe "Parser" do

  PMAIL = PerfectMail::PMAIL
  EL = PerfectMail::MJML::Element

  def expect_base(root, params)
    if params.has_key?(:body) 
      expect(root[:body]).to eq(params[:body])
    end
    if params.has_key?(:head) 
      expect(root[:head]).to eq(params[:head])
    end
    if params.has_key?(:styles) 
      expect(root[:styles]).to eq(params[:styles])
    end
    if params.has_key?(:sections) 
      expect(root[:sections]).not_to be_nil
      expect(root[:sections].count).to eq(params[:sections])
    end
  end

  it "produce a valid tree (root) with one paragraph" do
    src = <<~PMAIL.strip

    section
      My first text
    
    PMAIL

    r = PerfectMail::PMAIL.new(src).root

    # puts "roots:\n#{pmail.root.inspect}"
    expect_base(r, body: nil, head: nil, styles: nil, sections: 1)
    section = r[:sections].first
    expect(section).to be_instance_of(PerfectMail::MJML::Element::Section)
    children = section.children
    expect(children.count).to be(1)
    column = section.children.first
    expect(column).to be_instance_of(PerfectMail::MJML::Element::Column)
    expect(column.children.count).to be(1)
    text = column.children.first
    expect(text).to be_instance_of(PerfectMail::MJML::Element::Text)
    expect(text.value).to eq('My first text')
  end

  it "produce a valid tree with 2 paragraphs" do
    src = <<~PMAIL

    section
      My first paragraph
      My second paragraph

    PMAIL
  
    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, styles: nil, sections: 1)
    s1 = r[:sections][0]
    expect(s1.children.count).to be(1)
    c = s1.children.first
    expect(c).to be_instance_of(EL::Column)
    expect(c.children.count).to be(2)
    t1 = c.children[0]
    t2 = c.children[1]
    expect(t1.value).to eq('My first paragraph')
    expect(t2.value).to eq('My second paragraph')
  end

  it "produce a valid tree with 1 paragraph with style" do
    src = <<~PMAIL
    /*
      Début de commentaire
    */
    styles
      p: size=18pt; // pour ne pas générer d'alerte
    section
      column
        p: My first stylized paragraph

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 1)
    txts = r[:sections][0].children[0].children
    expect(txts.count).to be(1)
    t = txts[0]
    # puts "t.attrs: #{t.attrs.inspect}"
    expect(t).to be_instance_of(EL::Text)
    expect(t.value).to eq('My first stylized paragraph')
    expect(t.style).to eq('p')
  end

  it "reconnait les styles définis" do

    src = <<~PMAIL

    styles
      p: size:12pt; font:Arial;
      tiny: size: 8pt; style: italic;

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 0)
    styles = r[:styles]
    expect(styles).not_to be_nil
    expect(styles.children.count).to eq(2)
    sty1 = styles.children[0]
    expect(sty1).to be_instance_of(EL::Style)
    expect(sty1.name).to eq('p')
    sty2 = styles.children[1]
    expect(sty2).to be_instance_of(EL::Style)
    expect(sty2.name).to eq('tiny')
  end

  it "reconnait les images" do
    src = <<~PMAIL

    section
      img: monImage.jpg

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, styles: nil, sections: 1)
    expect(r[:sections].count).to eq(1)
    expect(r[:sections][0].children.count).to eq(1)
    c = r[:sections][0].children[0]
    expect(c.children.count).to eq(1)
    i = c.children[0]
    expect(i).to be_instance_of(EL::Image)
    expect(i.value).to eq('monImage.jpg')

  end

  it "reconnait les images avec style" do
    src = <<~PMAIL

    styles
      plain: width:200px; height:30px;

    section
      img: monImage.jpg|style:plain

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 1)
    c = r[:sections][0].children[0]
    expect(c.children.count).to eq(1)
    i = c.children[0]
    expect(i).to be_instance_of(EL::Image)
    expect(i.value).to eq('monImage.jpg')
    expect(i.style).to eq('plain')
  end

  it "reconnait un mélange d'images et de texte" do
    src = <<~PMAIL

    styles
      plain: width:200px; height:30px;

    section
      Un premier paragraphe
      img: doss/monImage.jpg|style:plain
      plain: Troisième paragraphe de type plain.
    section
      Juste un texte.
    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 2)
    c = r[:sections][0].children[0].children
    expect(c.count).to eq(3)
    p1 = c[0]
    p2 = c[1]
    p3 = c[2]
    expect(p1).to be_instance_of(EL::Text)
    expect(p1.value).to eq("Un premier paragraphe")
    expect(p2).to be_instance_of(EL::Image)
    expect(p2.value).to eq("doss/monImage.jpg")
    expect(p3).to be_instance_of(EL::Text)
    expect(p3.value).to eq('Troisième paragraphe de type plain.')
    p4 = r[:sections][1].children[0].children.first
    expect(p4).to be_instance_of(EL::Text)
    expect(p4.value).to eq('Juste un texte.')
  end

  it "reconnait une section à deux colonnes" do

    src = <<~PMAIL

    section
      column
        Un texte colonne 1.
        Un deuxième texte colonne 1.
      column
        Un texte colonne 2.

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 1)
    s = r[:sections][0]
    expect(s.children.count).to eq(2)
    c1 = s.children[0]
    c2 = s.children[1]
    expect(c1).to be_instance_of(EL::Column)
    expect(c2).to be_instance_of(EL::Column)
    expect(c1.children.count).to eq(2) # 2 texts in column A
    expect(c2.children.count).to eq(1) # 1 text in column 2
    t1 = c1.children[0]
    t2 = c1.children[1]
    t3 = c2.children[0]
    expect(t1).to be_instance_of(EL::Text)
    expect(t2).to be_instance_of(EL::Text)
    expect(t3).to be_instance_of(EL::Text)
    expect(t1.value).to eq('Un texte colonne 1.')
    expect(t2.value).to eq('Un deuxième texte colonne 1.')
    expect(t3.value).to eq('Un texte colonne 2.')

  end

  it "reconnait une section à 3 colonnes" do
    src = <<~PMAIL

    section
      column
        Sur colonne 1.
      column
        Sur colonne 2.
      column
        Sur colonne 3.

    PMAIL

    r = PMAIL.new(src).root
    expect_base(r, body: nil, head: nil, sections: 1)

  end

end