describe "Images" do

  Builder = PerfectMail::Builder

  def pmail2html(src)
    path = make_pmail_file_with_code(src)
    builder = Builder.new(path)
    expect { builder.build({}) }.not_to raise_error
    File.read(builder.html_path)
  end

  it "can be localy defined" do
    src = <<~PMAIL
    section
      img: spec/fixtures/mails/images/logo.jpg
    PMAIL
    html = pmail2html(src)
    expect(html).to match(/<img src="data:image\/jpg/)
  end

  it "can be remotely defined" do
    src = <<~PMAIL
    section
      img: www.atelier-icare.net/img/atelier/Icare/Icare-bigger.png | href=www.atelier-icare.net

    PMAIL
    html = pmail2html(src)
    expect(html).to match(/<img.+?src="https:\/\/www\.atelier-icare/)
    expect(html).to match(/<a href="https:\/\/www\.atelier\-icare/)
  end
end