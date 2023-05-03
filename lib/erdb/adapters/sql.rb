require "active_record"
require_relative "db"

module ERDB
  class SQL < Db
    #
    # Initialize a new SQL instance.
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
      puts "\n"
      puts "Connecting to #{@adapter} database..."

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
      puts "\nAnalyzing database..."

      raise "No tables found in database." if @connection.tables.empty?

      @connection.tables.map do |table|
        columns = @connection.columns(table).map { |column| { name: column.name, type: column.type || "unknown" } }
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
        hash[:is_junction_table] = junction_table?(hash)
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
    # Check current table is a junction table or not.
    #
    # @param table [Hash] The table to check.
    # @return [Boolean] True if the table is a junction table, false otherwise.
    #
    def junction_table?(table)
      relations = table[:relations]

      # remove data like id, created_at, updated_at
      columns = table[:columns].map { |c| c[:name] }.reject do |column|
        %w[id created_at updated_at].include?(column)
      end

      if relations.size == columns.size && relations.size >= 2
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
