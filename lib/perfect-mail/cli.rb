module PerfectMail
  class CLI
    
    class << self
      attr_reader :options
      attr_reader :command
      attr_reader :arguments
      
      def run(args)
        puts "-> CLI.run"
        if args.empty?
          show_mini_help
        else
          traite_args(args)
          if File.exist?(command) # La commande est en fait un fichier à traiter
            Builder.new(command).build(options)
          else
            puts "Je ne sais pas encore traiter #{command}.".red
          end
        end
      end

      def show_mini_help
        puts <<~TEXT.blue
        Usage: perfect-mail <path/to/mail.pmail>
        TEXT
      end


      SHORT_OPT_TO_REAL = {
        'm' => :minified,
        'c' => :clip,
        'o' => :output,
        'a' => :mail_app, # Pour faire le fichier pour Mail.app
      }
      def traite_args(args)
        @command    = nil
        @arguments  = []
        @options    = {}
        args.each do |arg|
          if arg == ''
            next
          elsif arg.start_with?('--')
            arg, value = arg[2..-1].split('=')
            value ||= true
            @options.store(arg.to_sym, value)
          elsif arg.start_with?('-')
            arg = SHORT_OPT_TO_REAL[arg[1..-1]]
            @options.store(arg.to_sym, true)
          elsif arg.match?('=')
          elsif @command.nil?
            @command = arg
          else
            @arguments << arg
          end
        end
      end
    end #/class << self
  end #/CLI
end #/module