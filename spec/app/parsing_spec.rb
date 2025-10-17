describe "Parser" do

  it "parse minimal code" do
    src = <<~PMAIL
    section
      My first texte
    PMAIL

    pmail = PerfectMail::PMAIL.new(src)

    puts "roots:\n#{pmail.root.inspect}"

  end
end