require "thor"
require "json"

module ERDB
  class Cli < Thor
    class_option :browser, type: :string, default: :chrome, enum: %w[chrome firefox], desc: "Browser to generate ERD"
    class_option :junction_table, type: :boolean, default: true, desc: "Display junction table in the diagram"

    desc "create", "Create ERD from database", hide: true
    def create
      ERDB.default_browser = options[:browser].to_sym
      ERDB.show_junction_table = options[:junction_table]

      ARGV.clear

      say Messages.welcome

      db = select_database

      erd_builder = select_diagram_builder

      db.connect

      erd_builder.create(db.to_erdb)
    rescue Interrupt
      say "\n\nThank you for using ERDB!", :blue
      exit 0
    rescue ActiveRecord::NoDatabaseError
      say "\nError: Database not found.", :red
      say "Please make sure the database exists."
      exit 1
    rescue StandardError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    default_task :create

    desc "-v --version", "Show version"
    map %w[-v --version] => :version
    def version
      say "ERDB #{ERDB::VERSION}"
    end

    desc "-h --help", "Show help"
    map %w[-h --help] => :help
    def help
      say Messages.help
      super
    end

    def self.exit_on_failure?
      true
    end

    private

    #
    # Ask user which database to use.
    # @return [Db]
    #
    def select_database
      data = {
        sqlite3: { name: "SQLite", gem: "sqlite3" },
        postgresql: { name: "PostgreSQL(Gem 'pg' must be installed)", gem: "pg" },
        mysql2: { name: "MySQL(Gem 'mysql2' must be installed)", gem: "mysql2" }
      }

      say "Select a database adapter:"

      data.each_with_index do |v, i|
        say "#{i + 1}. #{v[1][:name]}"
      end

      response = ask_number(1, data.size, ">")

      adapter = data.keys[response.to_i - 1].to_sym

      # check if the gem is installed
      # I don't want to include the gem in the gemspec file
      # cuz it's dependencies are too big and depend on the native library
      # I only include sqlite3 gem cuz it's small and doesn't have any dependencies
      gem = data[adapter][:gem]

      begin
        require gem
      rescue LoadError
        say "\nError: '#{gem}' gem is not installed."
        say "Please install the gem '#{gem}' first."
        say "Run 'gem install #{gem}' to install the gem."
        exit 1
      end

      database = if adapter == :sqlite3
                   say "\nEnter the path to the database file:"
                   ask_file "> "
                 else
                   ask "\nEnter the database connection string:\n>"
                 end

      return SQL.new(adapter, database) if %i[sqlite3 mysql2 postgresql].include?(adapter)

      raise "Invalid database adapter"
    end

    #
    # Select a diagram builder.
    # @return [ERDProvider]
    #
    def select_diagram_builder
      data = [Azimutt, DBDiagram]

      say "\nSelect a diagram builder:"

      data.each_with_index do |v, i|
        say "#{i + 1}. #{v.name.split('::').last}"
      end

      response = ask_number(1, data.size, ">")

      data[response.to_i - 1]
    end

    #
    # Ask a number input to the user.
    # @param [Integer] min
    # @param [Integer] max
    # @param [String] question
    # @return [Integer]
    #
    def ask_number(min, max, question)
      response = nil
      until response.to_i.between?(min, max)
        response = ask question
        unless response.match(/^\d+$/)
          say "Please enter a number"
          response = nil
        end

        unless response.to_i.between?(min, max)
          say "Please enter a number between #{min} and #{max}"
          response = nil
        end
      end
      response
    end

    #
    # Ask a file path to the user.
    # @param [String] question
    # @return [String]
    #
    def ask_file(question)
      loop do
        file = ask question
        return file if File.exist?(file)

        say "File not found", :red
      end
    end

    #
    # Ask a yes/no question to the user.
    # @param [String] question
    # @param [Boolean] default
    # @return [Boolean]
    #
    def ask_yes_no(question, default = true)
      result = ask question

      result.empty? ? default : result.downcase == "y"
    end
  end

  #
  # All the messages used in the CLI
  #
  class Messages
    def self.welcome
      <<~WELCOME
           .----------------.  .----------------.  .----------------.  .----------------.
          | .--------------. || .--------------. || .--------------. || .--------------. |
          | |  _________   | || |  _______     | || |  ________    | || |   ______     | |
          | | |_   ___  |  | || | |_   __ \\    | || | |_   ___ `.  | || |  |_   _ \\    | |
          | |   | |_  \\_|  | || |   | |__) |   | || |   | |   `. \\ | || |    | |_) |   | |
          | |   |  _|  _   | || |   |  __ /    | || |   | |    | | | || |    |  __'.   | |
          | |  _| |___/ |  | || |  _| |  \\ \\_  | || |  _| |___.' / | || |   _| |__) |  | |
          | | |_________|  | || | |____| |___| | || | |________.'  | || |  |_______/   | |
          | |              | || |              | || |              | || |              | |
          | '--------------' || '--------------' || '--------------' || '--------------' |
           '----------------'  '----------------'  '----------------'  '----------------'
        #{about}
        ERDB will use chrome as the default browser to automate the process.
        Use 'erdb --help' to see the available options.

      WELCOME
    end

    def self.help
      <<~HELP
        #{about}
        Usage:
          erdb [options]

        Examples:
          erdb --browser=firefox --no-junction-table

      HELP
    end

    def self.about
      <<~ABOUT
        ERDB is an automate tool to generate Entity-Relationship Diagrams from a database.
        It use Azimutt and DBDiagram to generate the diagrams.
      ABOUT
    end
  end
end
