describe "Builder" do

  Builder = PerfectMail::Builder
  
  it "produit les fichiers attendus" do
    path = File.absolute_path(File.join('.', 'spec', 'fixtures', 'mails', 'simple.pmail'))
    Builder.new(path).build({})
  end

  it "produit le fichier pour Mail.app" do
    path = File.absolute_path(File.join('.', 'spec', 'fixtures', 'mails', 'simple.pmail'))
    Builder.new(path).build({mail_app: true})
  end

  it "produces a mail for Mail.app with all the features (and opens it)" do
    fpath = fixture_path('mails/full.pmail')
    Builder.new(fpath).build({mail_app: true})
  end
end