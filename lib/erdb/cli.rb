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

        provider, database = select_database

        erd_builder = select_diagram_builder

        ERDB.show_join_table = ask_yes_no("\nDo you want to display join tables? (Y/n)", true)

        adapter = SQL.new(provider, database)
        adapter.connect
        tables = adapter.to_erdb

        puts "\nGenerating ERD..."

        erd_builder.create(tables)
      rescue RuntimeError => e
        puts "Error: #{e.message}"
        exit 1
      end

      private

      #
      # Ask user which database to use.
      # @return [Array]
      #
      def select_database
        data = {
          sqlite3: "SQLite",
          mysql2: "MySQL",
          postgresql: "PostgreSQL"
        }

        puts "Select a database adapter:"

        data.each_with_index do |v, i|
          puts "#{i + 1}. #{v[1]}"
        end

        response = ask_number(1, data.size)

        adapter = data.keys[response.to_i - 1].to_s

        if adapter == "sqlite3"
          database = ask "\nEnter the path to the database file:"

          unless File.exist?(database)
            puts "Error: File not found"
            exit 1
          end
        else
          database = ask "\nEnter the database connection string:"
        end

        [adapter, database]
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
