module PerfectMail
  class CLI
    class << self
      def run(args)
        puts "-> CLI.run"
        if args.empty?
          show_mini_help
        else
          puts "Je dois apprendre à jouer la commande."
        end
      end


      def show_mini_help
        puts <<~TEXT.blue
        Usage: perfect-mail <path/to/mail.pmail>
        TEXT
      end
    end #/class << self
  end #/CLI
end #/module