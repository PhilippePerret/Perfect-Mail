module PerfectMail
  class MJML
    class << self

      ##
      # @mail
      # @api
      #
      # Méthode qui transforme un code au format pmail
      # en code au format MJML
      def pmail2mjml(code)
        pmail = PMAIL.new(code)
        lines = ['<mjml>']
        lines += pmail.head2mjml if pmail.head?
        lines << pmail.body2mjml
        lines << '</mjml>'
        return lines.join("\n")
      end

    end #/class << self
  end #/MJML
end #/Module