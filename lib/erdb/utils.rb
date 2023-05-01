module ERDB
  class Utils
    class << self
      #
      # Display the ER Diagram required data.
      # @param [String] data
      # @param [String] provider
      # @return [void]
      #
      def display_output(data, provider)
        puts "### Copy following output to #{provider} if unexpected error happen ###"
        puts "### Start of output ###\n\n"
        puts data
        puts "\n### End of output ###"
      end

      #
      # Check if the current OS is macOS.
      # @return [Boolean]
      def is_mac?
        RbConfig::CONFIG["host_os"] =~ /darwin|mac os/
      end

      #
      # Convert the relations to ER Diagram format.
      # @param [Array] relations
      # @return [Array]
      # @example
      #   [
      #     {
      #       from: {
      #         table: "users",
      #         column: "id"
      #       },
      #         to: {
      #           table: "posts",
      #           column: "user_id"
      #       }
      #     }
      #   ]
      #   # => ["users.id", "posts.user_id"]
      def to_many_to_many(relations)
        relations.map do |relation|
          "#{relation[:to][:table]}.#{relation[:to][:column]}"
        end.uniq
      end
    end
  end
end
