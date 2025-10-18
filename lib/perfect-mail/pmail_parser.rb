=begin

Module dédié au parsing du code pmail

=end
require_relative 'mjml_elements'
module PerfectMail
class PMAIL

  KEYWORDS_ROOT_CONTAINERS = {
    'body'      => MJML::Element::Body,
    'head'      => MJML::Element::Head,
    'section'   => MJML::Element::Section,
    'styles'    => MJML::Element::Styles,
  }
  KEYWORDS_CONTAINERS = {
    'column'    => MJML::Element::Column,
    'accordeon' => MJML::Element::Accordeon,
    'caroussel' => MJML::Element::Caroussel,
    'group'     => MJML::Element::Group,
    'navbar'    => MJML::Element::NavBar,
    'wrapper'   => MJML::Element::Wrapper,
  }
  KEYWORDS_ELEMENTS = {
    'txt'   => MJML::Element::Text,
    'img'   => MJML::Element::Image,
    'btn'   => MJML::Element::Button,
    'fnt'   => MJML::Element::Font,
    'font'  => MJML::Element::Font,     # alternative
    'vue'   => MJML::Element::Preview,  # Vue (texte) dans l'inbox
    'tit'   => MJML::Element::Title,
    'title' => MJML::Element::Title,    # alternative
    'div'   => MJML::Element::Divider,  # Diviseur de vue
    'raw'   => MJML::Element::Raw,
    'air'   => MJML::Element::Spacer,   # space between two sections

  }


  def parse(code)
    @root = {body: nil, head: nil, styles: nil, sections: []}
    @current_node     = nil
    @current_section  = nil

    code
    .gsub(/\r/,'')
    .gsub(/\/\*(.+?)\*\//m, '')
    .gsub(/\/\/(.+?)$/, '')
    .split("\n")
    .each do |line|
      line = line.strip # not mind indent
      next if line.empty?
      # puts "\nCURRENT LINE : #{line.inspect}"
      kword, attrs = line.split(' ', 2)
      if KEYWORDS_ROOT_CONTAINERS[kword]
        @current_node = make_root_node(KEYWORDS_ROOT_CONTAINERS[kword], nil, attrs)
      elsif KEYWORDS_CONTAINERS[kword]
        @current_node = @current_section
        @current_node = make_node(KEYWORDS_CONTAINERS[kword], nil, attrs)
      else
        # Contained Element
        kword, value, attrs = parse_content_line(line)
        if KEYWORDS_ELEMENTS[kword]
          # New node
          # Can't become a container node (not the @current_node)
          make_node(KEYWORDS_ELEMENTS[kword], value, attrs)
        elsif @current_node.nil?
          raise "Any current node. Code should start with body, or styles, or section without leading space."
        elsif @current_node.addlinable?
          # If one can add line to current node
          @current_node.add_line(line)
        else
          # Simple line of text to add to current node
          # Note: Can't become a container node (not the @current_node)
          make_node(KEYWORDS_ELEMENTS['txt'], value, attrs)
        end
      end
    end
    @current_node = nil
  end #/parse

  # shortcut
  # @return [{String} kword, {String|Nil} value, {String | Nil} attrs]
  #
  # If line is raw text, kword is value.
  def parse_content_line(line)
    MJML::Element::AbstractElement.parse_content_line(line)
  end

  def make_root_node(node_klass, value, attrs)
    node = node_klass.new(self, value, attrs)
    if node.tag === 'section' 
      @root[:sections] << node
      @current_section = node
    else
      @root.store(node.tag.to_sym, node)
    end
    return node
  end

  def make_node(node_klass, value, attrs)
    node = node_klass.new(self, value, attrs)
    @current_node << node unless @current_node.nil?
    return node
  end

end #/class PMAIL
end #/module PerfectMail