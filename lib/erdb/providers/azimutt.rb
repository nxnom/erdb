require "clipboard"
require "watir"

module ERDB
  class Azimutt
    class << self
      #
      # Create a new ER Diagram using https://azimutt.app/.
      # @param [Hash] tables
      #
      def create(tables)
        converted_data = to_aml(tables)

        Utils.display_output(converted_data, "Azimutt")

        start_automation(converted_data)
      end

      private

      #
      # Start the automation process to generate the ER Diagram.
      # @param [String] data
      # @return [void]
      #
      def start_automation(data)
        browser = Watir::Browser.new

        browser.goto "https://azimutt.app/new"

        browser.span(text: "From scratch (db design)").click

        browser.button(id: "create-project-btn").click

        textarea = browser.textarea(id: "source-editor")
        textarea.click

        Clipboard.copy(data)

        # set! sometimes doesn't work cuz azimutt automatically reset incorrectly formatted data
        # and set is also slow as hell better to use send_keys
        # sometime naive is better than smart lol
        #
        # textarea.set(data)

        control = Utils.is_mac? ? :command : :control
        browser.send_keys control, "v"

        puts "Enter 'q' to quit."

        loop do
          v = gets.chomp
          break if v == "q"
        end

        browser.close
      end

      #
      # Convert the data to AML(Azimutt Markup Language) format.
      #
      # @param [Hash] tables
      # @return [String]
      #
      def to_aml(tables)
        str = ""
        tables.each_with_index do |table, i|
          if table[:is_join_table] && ERDB.hide_join_table?
            str += to_many_to_many_str(table)
            next
          end

          str += "\n\n" if i.positive?
          str += "#{table[:name]}\n"
          str += table[:columns].map { |c| to_column(c[:name], c[:type]) }.join("\n")

          # relations
          r = table[:relations]
          next if r.nil? || r.empty?

          r.each do |relation|
            str += "\n"
            f = relation[:from]
            t = relation[:to]

            str += "fk #{f[:table]}.#{f[:column]} -> #{t[:table]}.#{t[:column]}"
          end
        end
        str
      end

      #
      # Convert a column to a string.
      # @param [String] name
      # @param [String] type
      #
      def to_column(name, type)
        "  #{name} #{type}"
      end

      #
      # Convert a many-to-many table to a AML formatted string.
      # @param [Hash] table
      # @return [String]
      #
      def to_many_to_many_str(table)
        str = "\n"
        relations = Utils.to_many_to_many(table[:relations])

        # Azimutt doesn't support many-to-many relations
        # so we have to convert it to two one-to-many relations
        # Really weird but does the job :/
        relations.each do |relation|
          relations.each do |other|
            next if relation == other

            str += "\nfk: #{relation} -> #{other}\n"
          end
        end

        str
      end
    end
  end
end
