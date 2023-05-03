require "watir"

module ERDB
  class ERDProvider
    class << self
      #
      # Create a new ER Diagram.
      # @param [Hash] tables
      #
      def create(tables)
        raise NotImplementedError
      end

      private

      #
      # @return [Watir::Browser]
      #
      def browser
        @browser ||= Watir::Browser.new(ERDB.default_browser)
      end

      #
      # Wait for user to enter 'q' to quit.
      #
      def wait_to_quit
        puts "Enter 'q' to exit."

        loop do
          v = gets.chomp
          break if v == "q"
        end

        browser.close
      end
    end
  end
end
