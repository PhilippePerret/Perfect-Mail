=begin
  Ce module définit tous les éléments possibles dans le code MJML
=end
module PerfectMail
class MJML
class Element

  class AbstractElement

    def self.formate_attrs(instance, attrs)
      return '' if attrs.nil? || attrs.strip == ''
      attrs = ' ' + attrs
      .split(';')
      .reject{|defprop| defprop.strip == ''}
      .map do |defprop|
        prop, value = defprop.split(':').map { |s| s.strip }
        prop = instance.to_mjml_prop(prop)
        '%s="%s"' % [prop, value]
      end
      .join(' ')
    end


    attr_reader :pmail # instance PMail
    attr_reader :tag # body, section, column, etc.
    attr_reader :attrs # après le "|"
    attr_reader :data # les attributs en table
    attr_accessor :value
    attr_reader :children

    def initialize(pmail, line)
      @pmail = pmail
      parse(line || '')
      @children = []
    end

    def <<(child)
      @children << child
    end

    def parse(line)
      @tag, @attrs = line.split('|').map{|s| s.strip}
      parse_attrs
    end

    def parse_attrs
      @data = {}
      return if attrs.nil? || attrs.strip == ''
      attrs.split(';').each do |paire|
        prop, value = paire.split('=').map{|s| s.strip}
        @data.store(prop.to_sym, value)
      end
    end

    def to_mjml_prop(prop)
      case prop
      when 'size', 'fsize' then 'font-size'
      when 'font', 'ffamily', 'family' then 'font-family'
      when 'align' then 'text-align'
      when 'bgcolor' then 'background-color'
      when 'bg' then 'background'
      else prop
      end
    end

  end

  class Body < AbstractElement
    def initialize(pmail, attrs); super end

    # @return les lignes pour le body
    def to_mjml
      pmail.sections.map do |section|
        section.to_mjml
      end.flatten
    end
  end

  ## ====================================
  # Classe pour les STYLES
  #
  class Styles
    attr_reader :children
    attr_reader :pmail # instance PMail
    def initialize(pmail)
      @pmail = pmail
      @children = []
    end

    def any?; @children.any? end

    ##
    # L'ajout d'une line de style est toujours la définition
    # d'un nouveau style.
    def add_line(line)
      name, *attrs = line.split(':').map{|s| s.strip}
      attrs = attrs.join(':')
      @children << [name, attrs]
    end

    def to_mjml
      c = ['<mj-attributes>']
      children.each do |paire|
        name, attrs = paire
        c << to_class_def(paire)
      end
      c << '</mj-attributes>'
      return c
    end

    def to_class_def(paire)
      puts "paire = #{paire.inspect}"
      name, attrs = paire
      attrs = AbstractElement.formate_attrs(self, attrs)
      '<mj-class name="%s"%s />' % [name, attrs]
    end

    def to_mjml_prop(prop)
      case prop
      when 'size', 'fsize' then 'font-size'
      when 'font' then 'font-family'
      when 'fstyle' then 'font-style'
      when 'align' then 'text-align'
      else prop
      end
    end
  end #/class MJML::Element::Styles


  ## ========================================================
  #
  # Classe pour une SECTION
  #
  # Une section contient une ou plusieurs colonnes qui 
  # contiennent tous les éléments
  #
  class Section < AbstractElement
    attr_reader :columns

    def initialize(pmail, attrs)
      super 
      @columns = []
    end

    def add_line(line)
      # puts "\n-> Section.add_line avec '#{line}'"
      # puts "Nombre de colonnes = #{@columns.count}"
      # Si line commence par 'column', c'est la définition d'une
      # colonne, sinon, c'est forcément un élément dans une 
      # colonne unique qui n'est pas indiquée
      tag, attrs = line.split('|').map { |s| s.strip }
      if tag == 'column'
        init_column(attrs)
      else
        @current_column || init_column('')
        @current_column << column_element(tag, attrs)
      end
    end
    def init_column(attrs)
      @current_column = Column.new(pmail, attrs)
      @columns << @current_column
    end

    # @return l'élément de colonne défini par tag et attrs
    def column_element(tag, attrs)
      AnyElement.create(pmail, tag, attrs)
    end

    def to_mjml
      # puts "-> Section.to_mjml avec #{columns.count} colonnes."
      [
        '<mj-section>',
        columns.map {|c| c.to_mjml },
        '</mj-section>'
      ].flatten
    end
  end

  class Column < AbstractElement
    def initialize(pmail, attrs); super end

    def to_mjml
      # puts "-> Column.to_mjml avec #{children.count} enfants."
      c = []
      c << entete_mjml
      children.map do |child|
        c << child.to_mjml 
      end
      c << '</mj-column>'
      return c
    end

    def entete_mjml
      '<mj-column%s>' % [AbstractElement.formate_attrs(self, attrs)]
    end
  end


  class AnyElement < AbstractElement
    class << self

      # +tag+ et +props+ ont été découpés selon le "|". Donc
      # si c'est un paragraphe, dans tag, il y a 'txt' par
      # exemple et 'img' dans une image.
      #
      def create(pmail, tag, props)
        puts "tag: '#{tag}' / props: '#{props}'"
        if props.nil?
          tag, *props = tag.split(':').map { |s| s.strip }
          props = props.join(':')
        elsif tag.match?(/^([a-z]+)\:/)
          tag, *xprops = tag.split(':').map { |s| s.strip }
          if tag == 'img'
            props += ";scr=#{xprops.join(':')}"
          else
            props += ';' + xprops.join(':')
          end
        end

        classe = 
          case tag
          when 'txt', 'text'
            Text
          when 'img'
            Image
          else
            # Alors c'est un texte qui n'est pas introduit par txt:
            props = tag
            Text
          end
        classe.new(pmail, props)
      end
    end
  end #/class << self

  # ========================================================
  #
  # Classe pour les TEXTES
  #
  #
  class Text < AbstractElement
    attr_reader :value

    # Un Text a son propre parseur car il peut être formaté
    # de façon particulière
    def parse(line)
      if line.match?(/\:\:/)
        style, value = line.split('::')
        @attrs ||= ""
        @attrs << "mj-class:#{style};"
        @value = formate(value)
      else
        @value = formate(line)
      end
    end

    def formate(line)
      # Un peu de markdown
      line
      .gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      .gsub(/\*(.+?)\*/, '<em>\1</em>')
      .gsub(/__(.+?)__/, '<u>\1</u>')
      .gsub(/\-\-\-(.+?)\-\-\-/, '<stroke>\1</stroke>')
    end

    def src; @src ||= attrs[:src] end

    def to_mjml
      return [
        '<mj-text%s>%s</mj-text>' % [
          AbstractElement.formate_attrs(self, attrs), 
          value
        ]
      ]
    end

    def to_mjml_prop(prop)
      case prop
      when 'font' then 'font-family'
      else 
        super(prop)
      end
    end
  end


  ##
  # =========================================================
  #
  # Pour les IMAGES
  #
  #
  class Image < AbstractElement

    def initialize(pmail, attrs)
      super
      puts "Image Attrs = #{attrs.inspect}"
      puts "Image data = #{data.inspect}"
    end

    def to_html
      '<img src="data:image/png;base64,%s">' % [base64_encoded]
    end

    def base64_encoded
      Base64.strict_encode64(File.binread(src))
    end

    def src; @src ||= data[:src] end
    def href; @href ||= data[:href] end
    def to_mjml
      if File.size(src) > 30_000
        ['<mj-image src="%s" %s/>' % [src, attrs]]
      else
        [to_html]
      end
    end
  end

  class Button < AbstractElement
    def href; @href ||= attrs[:href] end
    def to_mjml
      ['<mj-button href="%s" %s>%s</mj-button>' % [href, attrs, value]]
    end
  end

end #/class Element
end #/class MJML
end #/PerfectMail