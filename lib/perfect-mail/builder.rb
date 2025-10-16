=begin

Module principal qui construit le fichier HTML à partir
du fichier .pmail

=end
module PerfectMail
class Builder

  attr_reader :pmail_path
  attr_reader :options

  def initialize(path)
    @pmail_path = path
  end

  def build(options)
    @options = options
    create_mjml_file
    producte_html_code
    put_code_in_clipboard
    puts "Code construit avec succès. Colle-le quelque part".green
    if options[:mail_app]
      produce_mail_app_mail
      puts "Mail pour Mail.app construit avec succès".green
      `open -a Mail.app "#{eml_path}"`
    end
  end

  def create_mjml_file
    File.write(mjml_path, MJML.pmail2mjml(File.read(pmail_path)))
  end

  def producte_html_code
    `mjml -o "#{html_path}" "#{mjml_path}"`
  end

  def produce_mail_app_mail
    File.write(eml_path, <<~TXT)
    Subject: #{subject}
    From: Quelquun<philippe.perret@yahoo.fr>
    To: Autre<philippe.perret@icare-editions.fr>
    Content-Type: text/html; charset=UTF-8

    #{File.read(html_path)}
    TXT
  end

  # Raccourci vers le sujet (sera ensuite déduit des données)
  def subject
    @subject ||= "Sujet provisoire"
  end

  def put_code_in_clipboard
    IO.popen('pbcopy', 'w') { |f| f << File.read(html_path) }
  end


  def mjml_path
    @mjml_path ||= File.join(folder, "#{root}.mjml")
  end

  def eml_path
    @eml_path ||= File.join(folder, "#{root}.eml")
  end

  def html_path
    @html_path ||= begin
      options[:output] || File.join(folder, "#{root}.html")
    end
  end

  def root
    @root ||= File.basename(pmail_path, File.extname(pmail_path))
  end

  def folder
    @folder ||= File.dirname(pmail_path)
  end

end #/class Builder
end #/module