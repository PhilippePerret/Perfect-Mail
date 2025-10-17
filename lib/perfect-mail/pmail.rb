=begin
  Module qui se charge de traiter le code pmail du
  mail produit par l'utilisateur
=end
module PerfectMail
class PMAIL
  class << self

  end #/class << self

  # Provided code (pmail)
  attr_reader :raw_code
  # Pmail Code Tree
  attr_reader :root

  ##
  # Instanciation avec le code brut du fichier .pmail
  def initialize(code)
    @raw_code = code
    parse(code)
  end

  # @return true if mjml code needs an head
  def head?
    styles.any?
  end

  # @return {Array} lines'head
  # Only called if needed
  def head2mjml
    c = []
    c << '<mj-head>'
    c << styles.to_mjml
    c << '</mj-head>'
    return c
  end

  # @return {Array} body's lines (all but the head)
  def body2mjml
    c = []
    c << '<mj-body>'
    c << body.to_mjml
    c << '</mj-body>'
    return c
  end

  
  # The Body element. Defined during parsing or now.
  def body
    @body ||= MJML::Element::Body.new(self)
  end

  # The Styles element. Defined during parsing or now.
  def styles
    @styles ||= MJML::Element::Styles.new(self)
  end

end #/class PMAIL
end #/module