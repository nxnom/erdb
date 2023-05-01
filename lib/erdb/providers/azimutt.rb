require "watir"

module ERDB
  class Azimutt
    class << self
      #
      # Generate a new ER Diagram using Azimutt.
      # @param [Hash] tables
      #
      def generate(tables)
        converted_data = to_aml(tables)

        puts "### Copy following output to Azimutt if unexpected error happen ###"
        puts "### Start of output ###\n\n"
        puts converted_data
        puts "\n\n### End of output ###"

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

        # set! sometimes doesn't work
        # cuz azimutt automatically reset incorrectly formatted data
        textarea.set(data)

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
    end
  end
end
