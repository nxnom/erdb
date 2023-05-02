require "json"

module ERDB
  class Cli
    class << self
      #
      # Start the CLI.
      # @param [Array] args
      # @return [void]
      #
      def start(_args)
        ARGV.clear

        welcome

        db = select_database

        erd_builder = select_diagram_builder

        ERDB.show_join_table = ask_yes_no("\nDo you want to display join tables? (Y/n)", true)

        db.connect

        erd_builder.create(db.to_erdb)
      rescue Interrupt
        puts "\n\nThank you for using ERDB!"
        exit 0
      rescue ActiveRecord::NoDatabaseError
        puts "\nError: Database not found."
        puts "Please make sure the database exists."
        exit 1
      rescue StandardError => e
        puts "Error: #{e.message}"
        exit 1
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

        puts "Select a database adapter:"

        data.each_with_index do |v, i|
          puts "#{i + 1}. #{v[1][:name]}"
        end

        response = ask_number(1, data.size)

        adapter = data.keys[response.to_i - 1].to_sym

        # check if the gem is installed
        # I don't want to include the gem in the gemspec file
        # cuz it's dependencies are too big and depend on the native library
        # I only include sqlite3 gem cuz it's small and doesn't have any dependencies
        gem = data[adapter][:gem]

        begin
          require gem
        rescue LoadError
          puts "\nError: '#{gem}' gem is not installed."
          puts "Please install the gem '#{gem}' first."
          puts "Run 'gem install #{gem}' to install the gem."
          exit 1
        end

        database = if adapter == :sqlite3
                     ask_file "\nEnter the path to the database file:"
                   else
                     ask "\nEnter the database connection string:"
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

        puts "\nSelect a diagram builder:"

        data.each_with_index do |v, i|
          puts "#{i + 1}. #{v.name.split('::').last}"
        end

        response = ask_number(1, data.size)

        data[response.to_i - 1]
      end

      #
      # Display welcome message.
      #
      def welcome
        puts <<~WELCOME
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

          ERDB is an automate tool to generate Entity-Relationship Diagrams from a database.
          It use Azimutt and DBDiagram to generate the diagrams.

        WELCOME
      end

      #
      # Ask a question to the user.
      # @param [String] question
      # @return [String]
      #
      def ask(question = nil)
        puts question if question
        print "> "
        gets.chomp
      end

      #
      # Ask a number input to the user.
      # @param [Integer] min
      # @param [Integer] max
      # @return [Integer]
      #
      def ask_number(min, max)
        response = nil
        until response.to_i.between?(min, max)
          response = ask
          unless response.match(/^\d+$/)
            puts "Please enter a number"
            response = nil
          end

          unless response.to_i.between?(min, max)
            puts "Please enter a number between #{min} and #{max}"
            response = nil
          end
        end
        response
      end

      def ask_file(question)
        loop do
          file = ask question
          return file if File.exist?(file)

          puts "Invalid file path"
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
  end
end
