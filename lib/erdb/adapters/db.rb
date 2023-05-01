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
    #  [
    #    {
    #      name: "table_name",
    #      is_join_table: false,
    #      columns: ["column_name", "column_name", "column_name"],
    #      relations: [
    #        {
    #          from: {
    #            table: "table_name",
    #            column: "column_name"
    #          },
    #          to: {
    #            table: "table_name",
    #            column: "column_name"
    #          }
    #        }
    #        ...
    #      ]
    #    }
    #    ...
    #  ]
    #
    def to_erdb
      raise "[to_erdb] Not implemented."
    end
  end
end
