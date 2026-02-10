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
    affine_html_code # <=== AJOUTÉ POUR FAIRE DES MINICORRECTIONS DE FIN
    put_code_in_clipboard
    puts Msg(1).green
    if options[:mail_app]
      produce_mail_app_mail
      puts Msg(2).green
      `open -a Mail.app "#{eml_path}"`
    end
  end


  def affine_html_code
    code_ini = IO.read(html_path)
    puts "code_ini:\n#{code_ini}"
    code_ini.match?(/<td/) || raise("Ne contient pas <td")
    code_ini.match?(/padding:/) || raise("Ne contient pas padding:")
    code_ini.match?(/<td(.+?)padding\: ?/) || raise("ne contient pas l'expression")
    code = code_ini.to_str
      .gsub(/<td(.+?)padding\: ?20px/, '<td\1padding: 4px')
      .gsub(/<td(.+?)padding\: ?10px/, '<td\1padding: 2px')
    if code == code_ini
      puts "Aucune correction"
      exit 1
    end
    if File.exist?(remp_path)
      require remp_path
      REMPLACEMENTS.each do |search, remp|
        code = code.gsub(search, remp)
      end
    end

    IO.write(html_path, code)
  end

  def create_mjml_file
    File.write(mjml_path, MJML.pmail2mjml(File.read(pmail_path), self))
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

  # Fichier contenant les remplacements à faire
  def remp_path
    @remp_path ||= File.join(folder, 'remplacements.rb')
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
    @folder ||= File.absolute_path(File.dirname(pmail_path))
  end

end #/class Builder
end #/module