=begin

Traitement complet d'un fichier PMAil

Sans passer par autre chose.

@usage

  MJMLDealer.treate(path/to/file)

=end
require "fastimage"

class MJMLDealer

  def self.treate(path)
    dealer = MJMLDealer.new(path)
    dealer.treate
    put_code_in_clipboard(dealer)
  end


  def self.put_code_in_clipboard(dealer)
    IO.popen('pbcopy', 'w') { |f| f << File.read(dealer.html_path) }
    puts "Le code HTML a été mis dans le presse-papier. Vous pouvez le coller dans le formulaire Brevo par exemple.".vert
  end

  attr_reader :path, :mjml_code

  def initialize(path)
    @path = path
  end

  def treate
    parser    = MJMLParser.new(self)
    table = parser.parse
    composer  = MJMLComposer.new(self)
    @mjml_code = composer.compose(table)
    File.write(mjml_path, @mjml_code)
    # On produit le code HTML final
    builder = MJMLBuilder.new(self)
    builder.output(:html)
  end

  def pmail_path
    @pmail_path ||= File.join(folder, "#{base}.pmail")
  end
  def html_path
    @html_path ||= File.join(folder, "#{base}.html")
  end
  def mjml_path
    @mjml_path ||= File.join(folder, "#{base}.mjml")
  end
  def base
    @base ||= File.basename(path, File.extname(path))
  end
  def folder
    @folder ||= File.dirname(path)
  end
end



=begin
class MJMLBuilder
-----------------
Classe permettant de produire le code HTML final
=end
class MJMLBuilder
  attr_reader :dealer

  def initialize(dealer)
    @dealer = dealer
  end

  def output(format)
    case format
    when :html
      `mjml -o "#{dealer.html_path}" "#{dealer.mjml_path}"`
    else "Je ne connais pas le format #{format}"
    end
  end

end

=begin
Class MJMLComposer
------------------
Classe permettant de composer le code MJML du mail après l'avoir
parsé.
=end
class MJMLComposer
  attr_reader :dealer
  def initialize(dealer)
    @dealer = dealer
  end


  def compose(table)
    code = []
    code << '<mjml>'
    # - Début de head -
    code << '<mj-head>'
    table[:head].each { |line| code << line }
    if table[:all] || table[:class].count
      code << '<mj-attributes>'
      code << table[:all] unless table[:all].nil?
      table[:class].each { |line| code << line }
      code << '</mj-attributes>'
    end
    code << '</mj-head>'
    # / fin de head

    # - Début du body -
    code << '<mj-body>'
    table[:body].each do |item|
      if item.is_a?(String)
        code << item
      elsif item[:type] == :section
        code << ('<mj-section%s>' % [item[:attrs]])
        item[:columns].each do |column|
          code << ('<mj-column%s>' % [column[:attrs]])
          column[:items].each { |item| code << item }
          code << '</mj-column>'
        end
        code << '</mj-section>'
      end
    end

    code << '</mj-body>'    
    # / Fin du body -

    code << '</mjml>'


    return code.join("\n")
  end

end

=begin
Class MJMLparser
------------------
Classe permettant de parser le code PMAil pour le composer ensuite.
=end
class MJMLParser

  attr_reader :dealer
  def initialize(dealer)
    @dealer = dealer
  end

  def parse()
    code = File.read(dealer.pmail_path)
    table = {
      head:     [],
      all:      nil,  # sera mis dans mj-head > mj-attributes
      class:    [],   # sera mis dans mj-head > mj-attributes
      body:     [],
      sections: []
    }

    @current_section = nil
    @current_column = nil
    @current_element = nil

    code.split("\n").each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('# ')
      first_word, value = line.splittrim(' ', 2)
      value, attrs      = decompose_value_and_attributes(value || '')

      # Débug
      # puts "========\nfirst_word: #{first_word.inspect}\nvalue: #{value.inspect}\nattrs: #{attrs.inspect}\n========="
      # /DÉBUG

      case first_word
      when 'section'
        @current_section = {type: :section, columns: []}
        table[:body] << @current_section
        @current_column = nil
      when 'column'
        make_current_column(attrs)
      when 'text'
        traite_texte(value, attrs)
      when 'img'
        make_current_column if @current_column.nil?
        @current_column[:items] << traite_image(value, attrs)
      when 'font'
        name, href = value.splittrim(' ', 2)
        href = "https://#{href}" unless href.start_with?('http')
        table[:head] << ('<mj-font name="%s" href="%s" />' % [name, href])
      when 'title'
        table[:head] << ('<mj-title%s>%s</mj-title>' % [attrs, value])
      when 'preview'
        table[:head] << ('<mj-preview%s>%s</mj-preview>' % [attrs, value])
      when 'all'
        table.store(:all, '<mj-all%s />' % [css_attributes_to_mjml_attributes(value)])
      when 'class'
        name, attrs = value.splittrim(' ', 2)
        table[:class] << ('<mj-class name="%s" %s />' % [name, css_attributes_to_mjml_attributes(attrs)])
      when 'breakpoint'
        table[:head] << ('<mj-breakpoint%s width="%s" />' % [attrs, value])
      else
        # Si ça ne répond à rien, c'est un texte
        traite_texte("#{first_word} #{value}", attrs)
      end
    end

    return table
  end #/parse


  def make_current_column(attrs = '')
    # puts "-> make_current_column / attrs = #{attrs}".blue
    @current_column = {type: :column, items: [], attrs: attrs}
    @current_section[:columns] << @current_column
  end

  REG_CLASS = /^([a-zA-Z0-9_\-\:]+): /.freeze
  def traite_texte(str, attrs)
    make_current_column if @current_column.nil?
    if str.match?(REG_CLASS)
      classes = nil
      str = str.gsub(REG_CLASS) {
        classes = $1.freeze.split(':')
        ''
      }
      attrs += ' css-class="%s"'.freeze % classes.join(' ')
    end
    @current_column[:items] << ('<mj-text%s>%s</mj-text>' % [attrs, Formater.text(str)])
  end

  # Traite le code d'une image, c'est-à-dire, précisément, ce qui se
  # trouve après le 'img ' dans le code pmail
  # Comme tout élément, elle peut posséder des caractéristiques
  def traite_image(src, attrs)
    # ⚠️ Si les attributs définissent la hauteur (height) mais pas la
    #    largeur, il faut la calculer pour la forcer
    src = "https://#{src}"
    if (attrs.match?(/height="/) && !attrs.match?(/width="/))
      height = attrs.match(/height="(.+?)px"/)[1].to_i
      rwidth, rheight = FastImage.size(src, raise_on_failure: true)
      if rwidth.nil? || rheight.nil?
        puts "L'image #{src} semble introuvable…".red
      else
        ratio = rwidth.to_f / rheight
        width = (ratio * height).round
        attrs += " width=\"#{width}px\""
      end
    end
    ('<mj-image src="%s"%s />' % [src, attrs])
  end


  # @return le texte seul et les attributs, qui ont été transformés
  # en attributs pour la balise. Par exemple, "width:200px" sera 
  # transformé en ' width="200px"'
  def decompose_value_and_attributes(code)
    # puts "-> decompose_value_and_attributes(code = #{code.inspect})".blue
    return [code, ''] unless code.match?('\|')
    code, attrs = code.splittrim('|')
    [code, css_attributes_to_mjml_attributes(attrs)]
  end

  def css_attributes_to_mjml_attributes(attrs)
    ' ' + attrs.splittrim(';').map do |paire|
      prop, value = paire.splittrim(':')
      prop = PROP2ATTR[prop] || prop
      "#{prop}=\"#{value}\""
    end.join(' ')
  end


  PROP2ATTR = {
    'font'        => 'font-family',
    'size'        => 'font-size',
    'style'       => 'font-style',
    'weight'      => 'font-weight',
    'background'  => 'background-color',
    'bg'  => 'background-color'
  }

end # class MJMLParser