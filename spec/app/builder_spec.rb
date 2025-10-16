describe "Le contructeur" do
  
  it "produit les fichiers attendus" do
    path = File.absolute_path(File.join('.', 'spec', 'fixtures', 'mails', 'simple.pmail'))
    PerfectMail::Builder.new(path).build({})
  end

  it "produit le fichier pour Mail.app" do
    path = File.absolute_path(File.join('.', 'spec', 'fixtures', 'mails', 'simple.pmail'))
    PerfectMail::Builder.new(path).build({mail_app: true})
  end
end