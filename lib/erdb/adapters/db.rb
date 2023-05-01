module ERDB
  class Db
    class << self
      #
      # Connect to a database.
      #
      def connect
        raise "[connect] Not implemented."
      end

      #
      # Disconnect from a database.
      #
      def disconnect
        raise "[disconnect] Not implemented."
      end

      #
      # Convert database tables to ERD convertable Array.
      # @return [Array] The converted hash format.
      # @example The converted hash format:
      # [
      #   {
      #     name: "table_name",
      #     is_join_table: false,
      #     columns: ["column_name", "column_name", "column_name"],
      #     relations: [
      #       {
      #         from: {
      #           table: "table_name",
      #           column: "column_name"
      #         },
      #         to: {
      #           table: "table_name",
      #           column: "column_name"
      #         }
      #       }
      #       ...
      #     ]
      #   }
      #   ...
      # ]
      #
      def to_erdb
        raise "[to_erdb] Not implemented."
      end
    end
  end
end
