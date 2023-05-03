require "clipboard"
require "watir"

module ERDB
  class DBDiagram < ERDProvider
    class << self
      #
      # Create a new ER Diagram using https://dbdiagram.io
      # @param [Hash] tables
      #
      def create(tables)
        converted_data = to_dbdiagram_format(tables)

        Utils.display_output(converted_data, "DBDiagram")

        start_automation(converted_data)
      end

      private

      #
      # Start the automation process to generate the ER Diagram.
      # @param [String] data
      # @return [void]
      #
      def start_automation(data)
        browser.goto "https://dbdiagram.io/d"

        editor = browser.div(class: "view-lines monaco-mouse-cursor-text")
        editor.click

        control = Utils.is_mac? ? :command : :control

        browser.send_keys control, "a"
        browser.send_keys :delete

        old_clipboard = Clipboard.paste
        # Yep, I know this is ugly.
        # But DBDiagram don't use input element for editor. -_-
        Clipboard.copy(data)

        browser.send_keys control, "v"

        Clipboard.copy(old_clipboard)

        wait_to_quit
      end

      #
      # Convert the data DBDiagram string format.
      #
      # @param [Hash] tables
      # @return [String]
      #
      def to_dbdiagram_format(tables)
        str = ""
        tables.each_with_index do |table, i|
          if table[:is_junction_table] && !ERDB.show_junction_table
            str += to_many_to_many_str(table)
            next
          end

          str += "\n" if i.positive?
          str += "Table #{table[:name]} {\n"
          str += table[:columns].map { |c| to_column(c[:name], c[:type]) }.join("\n")
          str += "\n}\n"

          r = table[:relations]
          next if r.nil? || r.empty?

          r.each do |relation|
            str += "\n"
            f = relation[:from]
            t = relation[:to]

            str += "Ref: #{f[:table]}.#{f[:column]} > #{t[:table]}.#{t[:column]}"
          end

          str += "\n"
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
      # Convert a many-to-many table to a dbdiagram formatted string.
      # @param [Hash] table
      # @return [String]
      #
      def to_many_to_many_str(table)
        str = ""
        relations = Utils.to_many_to_many(table[:relations])

        relations.each_with_index do |relation, i|
          next if i.zero?

          str += "\nRef: #{relations.first} <> #{relation}\n"
        end

        str
      end
    end
  end
end
