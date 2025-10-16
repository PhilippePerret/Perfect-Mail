=begin
  Module qui se charge de traiter le code pmail du
  mail produit par l'utilisateur
=end
module PerfectMail
class PMAIL
  class << self

  end #/class << self

  attr_reader :raw_code
  attr_reader :sections

  ##
  # Instanciation avec le code brut du fichier .pmail
  def initialize(code)
    @raw_code = code
    @sections = []
    parse(code)
  end

  # @return true si le code mjml a besoin d'une entête
  # Pour le moment, c'est nécessaire lorsqu'il y a des styles
  def head?
    styles.any?
  end

  # @return les lignes pour définir le head
  # Pour le moment, il n'y a que les styles
  # Noter que cette méthode n'est appelée que si le head doit
  # vraiment être marqué
  def head2mjml
    c = []
    c << '<mj-head>'
    c << styles.to_mjml
    c << '</mj-head>'
    return c
  end

  # @return les lignes définissant le body, donc tout à part
  # le head (ci-dessus)
  def body2mjml
    c = []
    c << '<mj-body>'
    c << body.to_mjml
    c << '</mj-body>'
    return c
  end

  # Parse le code
  # -------------
  # On regroupe déjà par grands éléments qui ne peuvent être
  # que :
  #   body      (un seul)
  #   styles    (un seul)
  #   section   (plusieurs)
  #
  # Ensuite, chaque élément est parsé suivant son contenu
  #
  def parse(code)
    lines = code.gsub(/\r/,'').split("\n")
    current_node = nil
    while line = lines.shift
      indent = line.index(/\S/) || next
      if indent == 0
        # Un élément racine
        tag, attrs = line.strip.split('|')
        case tag
        when 'body' then 
          @body = MJML::Element::Body.new(self, attrs)
          current_node = @body
        when 'styles' then 
          @styles = MJML::Element::Styles.new(self)
          current_node = @styles
        when 'section' then
          current_node = MJML::Element::Section.new(self, attrs)
          @sections << current_node
        else 
          raise "Unknown root tag: #{tag} (available: body, styles, section)"
        end
      elsif current_node.nil?
        raise "Any current node. Code should start with body, or styles, or section without leading space."
      else
        current_node.add_line(line)
      end
    end
  end

  # L'élément Body. Soit il a été défini au cours du parsing du
  # mail, soit on le définit ici
  def body
    @body ||= MJML::Element::Body.new(self, '')
  end

  # L'élément Styles. Soit il a été défini au cours du parsing,
  # soit on le définit ici
  def styles
    @styles ||= MJML::Element::Styles.new(self)
  end

end #/class PMAIL
end #/module