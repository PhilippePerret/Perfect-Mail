=begin
  Ce module définit tous les éléments possibles dans le code MJML
=end
module PerfectMail
class MJML
class Element

  class AbstractElement

    # @return formatted attributes for mjml code
    def self.formate_attrs(instance, attrs)
      # puts "-> formate_attrs(attrs : #{attrs.inspect})"
      return '' if attrs.nil? || attrs.empty?
      attrs
      .map do |k, v|
        k = instance.to_mjml_prop(k)
        '%s="%s"' % [k, v]
      end
      .join(' ')
      .prepend(' ')
    end

    # Parse a raw text line (without leading word)
    def self.parse_content_line(line)
      kword = value = attrs = nil
      if line.match?(/^([a-z]+)\:/)
        kword, value = line.split(':', 2).map {|s| s.strip }
        value, attrs = value.split('|', 2)
        # If kword is not a known keywords, it's the name of a class
        unless PMAIL::KEYWORDS_ELEMENTS[kword] || PMAIL::KEYWORDS_ROOT_CONTAINERS[kword] || PMAIL::KEYWORDS_CONTAINERS[kword]
          if attrs.nil?
            attrs = ''
          elsif !attrs.end_with?(';')
            attrs += ';'
          end
          attrs += "style:#{kword};"
        end
      else
        value = line.strip
      end
      [kword, value, attrs]
    end


    # {PerfectMail::PMail} instance
    attr_reader :pmail
    # {Hash} Table of attributes
    attr_reader :attrs
    # {String} Value for contained element (p.e. text)
    attr_reader :value
    # Node children
    attr_reader :children

    def initialize(pmail, value, attrs)
      @pmail = pmail
      @value = value
      parse_raw_attrs(attrs)
      @children = []
    end

    def inspect
      {
        tag: tag,
        # root?: root?,
        :"children(#{children.count})" => children,
        attrs: attrs,
        value: value,
        eoh: 'EOH' # to visualize end of hash
    }.inspect
    end

    # === Volatile Properties ===

    def src; @src ||= attrs[:src] end
    def style; @style ||= attrs[:style] end

    # === Predicates ===

    def root?; false end
    # @return True if element can receave raw lines of text
    def addlinable?; false end

    # @return True si node has children
    def any?; children.any? end

    # To add a Node
    # @params child {MJML::Element::...}
    def <<(child)
      @children << child
    end

    # To parse raw attributes provided at initialization
    def parse_raw_attrs(raw_attrs)
      @attrs = {}
      return if raw_attrs.nil? || raw_attrs.strip == ''
      raw_attrs.split(';').each do |paire|
        prop, value = paire.split(/[=:]/,2).map{|s| s.strip}
        @attrs.store(prop.to_sym, value)
      end
    end

    # Short CSS prop to real one
    def to_mjml_prop(prop)
      # puts "-> to_mjml_prop(prop = #{prop.inspect})"
      case prop.to_s
      when 'style' then 'mj-class'
      when 'size', 'fsize' then 'font-size'
      when 'font', 'ffamily', 'family' then 'font-family'
      when 'align' then 'text-align'
      when 'bgcolor' then 'background-color'
      when 'bg' then 'background'
      else prop
      end
    end

  end

  ## ====================================
  # Class for --- BODY
  #
  class Body < AbstractElement
    def tag; 'body' end
    def root?; true end

    # @return {Array} MJML's lines to mljm file
    def to_mjml
      pmail.sections.map do |section|
        section.to_mjml
      end.flatten
    end
  end

  ## ====================================
  # Class for --- HEAD
  #
  class Head < AbstractElement
    def tag; 'head' end
    def root?; true end
  end

  ## ====================================
  # Class for --- FONTS
  #
  class Fonts < AbstractElement
    def tag; 'fonts' end
    def root?; true end
    def addlinable?; true end

    def add_line(line)
      name, href = line.split(':', 2).map{|s|s.strip}
      href || raise(Err(1000, [name]))
      href = "https://#{href}" unless href.start_with?('http')
      font = Font.new(pmail, name, "href=#{href};")
      @children << font
    end

    def to_mjml
    end
  end #/ Fonts

  ## ====================================
  # Class for --- FONT
  #
  class Font < AbstractElement
    def tag; 'font' end
    def name; value end
    def href; @href ||= attrs[:href] end
    def to_mjml
      ['<mj-font name="%" href="%s" />' % [name, href]]
    end
  end



  ## ====================================
  # Class for --- STYLES
  #
  class Styles < AbstractElement
    def tag; 'styles' end
    def root?; true end
    def addlinable?; true end

    ##
    # A line should always be a style definition. So a 
    # keyword (style name) and CSS's classes
    def add_line(line)
      name, attrs = line.split(':', 2).map{|s| s.strip}
      style = Style.new(pmail, name, attrs)
      @children << style
    end

    def to_mjml
      c = ['<mj-attributes>']
      c += children.map do |style| style.to_mjml end
      c << '</mj-attributes>'
      return c
    end

  end #/class MJML::Element::Styles

  ## ====================================
  # Class for --- STYLE
  #
  # A style
  class Style < AbstractElement
    def tag; 'style' end
    def name; @value end

    def to_mjml
      fattrs = AbstractElement.formate_attrs(self, attrs)
      '<mj-class name="%s"%s />' % [name, fattrs]
    end

  end




  ## ========================================================
  #
  # Class for --- SECTION
  #
  # Une section contient une ou plusieurs colonnes qui 
  # contiennent tous les éléments
  #
  # Note: Section's children are columns.
  #
  class Section < AbstractElement
    def tag; 'section' end
    def root?; true end
    def addlinable?; true end

    # So a line unknowable (not a column), so a text
    def add_line(line)
      kword, value, attrs = AbstractElement.parse_content_line(line)
      child = Text.new(pmail, value, attrs)
      @current_column ||= init_column
      @current_column << child
    end

    # To add a Node (a column or a text, or a image)
    # @params child {MJML::Element::Column|Text|Image}
    def <<(child)
      if child.tag == 'column'
        @children << child
      else
        @current_column ||= init_column
        @current_column << child
      end
    end

    # Init a new column (for a lonely text in a section with only
    # one non explicit column)
    def init_column
      Column.new(pmail, nil, nil).tap {|column| @children << column }
    end

    def to_mjml
      # puts "-> Section.to_mjml avec #{columns.count} colonnes."
      [
        '<mj-section>',
        children.map {|c| c.to_mjml },
        '</mj-section>'
      ].flatten
    end
  end

  ## ====================================
  # Class for --- COLUMN
  #
  class Column < AbstractElement
    def tag; 'column' end

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

  # ========================================================
  #
  # Class for --- TEXT
  #
  #
  class Text < AbstractElement
    def tag; 'text' end

    # # Un Text a son propre parseur car il peut être formaté
    # # de façon particulière
    # def parse(line)
    #   if line.match?(/\:\:/)
    #     style, value = line.split('::')
    #     @attrs ||= ""
    #     @attrs << "mj-class:#{style};"
    #     @value = formate(value)
    #   else
    #     @value = formate(line)
    #   end
    # end

    def formate(str)
      # Un peu de markdown
      str
      .gsub(/\*\*(.+?)\*\*/, '<strong>\1</strong>')
      .gsub(/\*(.+?)\*/, '<em>\1</em>')
      .gsub(/__(.+?)__/, '<u>\1</u>')
      .gsub(/\-\-\-(.+?)\-\-\-/, '<stroke>\1</stroke>')
    end

    def to_mjml
      return [
        '<mj-text%s>%s</mj-text>' % [
          AbstractElement.formate_attrs(self, attrs), 
          formate(value)
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


  # =========================================================
  #
  # Class for --- IMAGE
  #
  #
  class Image < AbstractElement
    def tag; 'image' end

    def to_html
      '<img src="data:image/png;base64,%s">' % [base64_encoded]
    end

    def base64_encoded
      Base64.strict_encode64(File.binread(src))
    end

    def src; @src ||= attrs[:src] end
    def href; @href ||= attrs[:href] end
    def to_mjml
      if File.size(src) > 30_000
        ['<mj-image src="%s" %s/>' % [src, attrs]]
      else
        [to_html]
      end
    end
  end

  ## ====================================
  # Class for --- BUTTON
  #
  class Button < AbstractElement
    def tag; 'button' end

    def href; @href ||= attrs[:href] end
    def to_mjml
      ['<mj-button href="%s" %s>%s</mj-button>' % [href, attrs, value]]
    end
  end

  ## ====================================
  # Class for --- FONT
  #
  class Font < AbstractElement
    def tag; 'font' end
  end

  ## ====================================
  # Class for --- PREVIEW
  #
  class Preview < AbstractElement
    def tag; 'preview' end
  end

  ## ====================================
  # Class for --- TITLE
  #
  class Title < AbstractElement
    def tag; 'title' end
  end

  ## ====================================
  # Class for --- DIVIDER
  #
  class Divider < AbstractElement
    def tag; 'divider' end
  end

  ## ====================================
  # Class for --- RAW
  #
  class Raw < AbstractElement
    def tag; 'raw' end
  end

  ## ====================================
  # Class for --- SPACER
  #
  class Spacer < AbstractElement
    def tag; 'spacer' end
  end


  ## ====================================
  # Class for --- ACCORDEON
  #
  class Accordeon < AbstractElement
    def tag; 'accordeon' end
  end

  ## ====================================
  # Class for --- CAROUSSEL
  #
  class Caroussel < AbstractElement
    def tag; 'caroussel' end
  end

  ## ====================================
  # Class for --- GROUP
  #
  class Group < AbstractElement
    def tag; 'group' end
  end

  ## ====================================
  # Class for --- NAVBAR
  #
  class NavBar < AbstractElement
    def tag; 'navbar' end
  end

  ## ====================================
  # Class for --- WRAPPER
  #
  class Wrapper < AbstractElement
    def tag; 'wrapper' end
  end







end #/class Element
end #/class MJML
end #/PerfectMail