module ERDB
  class Db
    #
    # @param adapter [String] The adapter to use.
    # @param database [String] The database to connect to.
    # @return [void]
    #
    def initialize(adapter, database)
      @adapter = adapter
      @database = database
    end

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
    # @return [Array] The converted hash format. see example result below.
    #
    # @example Example result:
    # ```ruby
    # [
    #   {
    #     name: "table_name",
    #     is_junction_table: false,
    #     columns: [{ name: "column_name", type: "column_type" }, ...],
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
    #  ```
    #
    def to_erdb
      raise "[to_erdb] Not implemented."
    end
  end
end
