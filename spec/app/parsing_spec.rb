describe "Parser" do

  it "produce a valid tree (root) with one paragraph" do
    src = <<~PMAIL.strip

    section
      My first text
    
    PMAIL

    pmail = PerfectMail::PMAIL.new(src)

    # puts "roots:\n#{pmail.root.inspect}"
    r = pmail.root
    expect(r[:body]).to be_nil
    expect(r[:styles]).to be_nil
    expect(r[:head]).to be_nil
    sections = r[:sections]
    expect(sections.count).to be(1)
    section = sections.first
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

  it "produce a valid tree with 2 paragraph" do
    src = <<~PMAIL
    section
      My first paragraph
      My second paragraph
    PMAIL
  end
end