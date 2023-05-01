require "active_record"
require_relative "db"

module ERDB
  class SQL < Db
    #
    # Initialize a new SQL instance.
    # @param adapter [String] The adapter to use.
    # @param database [String] The database to connect to.
    # @return [void]
    #
    def initialize(adapter, database)
      super

      @db = ActiveRecord::Base
      @connection = nil
    end

    #
    # Connect to a database.
    #
    def connect
      case @adapter.to_sym
      when :sqlite3
        connect_sqlite3
      when :postgresql, :mysql2
        connect_with_connection_string
      else
        raise "Adapter not supported."
      end

      @connection = @db.connection
    end

    #
    # Convert database tables to ERD convertable Array.
    #
    def to_erdb
      @connection.tables.map do |table|
        columns = @connection.columns(table).map(&:name)
        relations = @connection.foreign_keys(table).map do |fk|
          {
            from: {
              table: table,
              column: fk.options[:column]
            },
            to: {
              table: fk[:to_table],
              column: fk.options[:primary_key]
            }
          }
        end

        hash = { name: table, columns: columns, relations: relations }
        hash[:is_join_table] = join_table?(hash)
        hash
      end
    end

    #
    # Disconnect from a database.
    #
    def disconnect
      @db.remove_connection
      @connection = nil
    end

    private

    #
    # Check current table is a join table or not.
    #
    # @param table [Hash] The table to check.
    # @return [Boolean] True if the table is a join table, false otherwise.
    #
    def join_table?(table)
      relations = table[:relations]

      # remove data like id, created_at, updated_at
      columns = table[:columns].reject do |column|
        %w[id created_at updated_at].include?(column)
      end

      if relations.size == columns.size
        columns.include?(relations[0][:from][:column]) && columns.include?(relations[1][:from][:column])
      else
        false
      end
    end

    #
    # Connect to a SQLite3 database.
    # @param database [String] The database to connect to.
    # @raise [RuntimeError] If the database does not exist.
    #
    def connect_sqlite3
      raise "Database does not exist." unless File.exist?(@database)

      @db.establish_connection(
        adapter: :sqlite3,
        database: @database
      )
    end

    #
    # Connect to a PostgreSQL or MySQL database.
    # @param database [String] The database to connect to.
    #
    def connect_with_connection_string
      @db.establish_connection(@database)
    end
  end
end
