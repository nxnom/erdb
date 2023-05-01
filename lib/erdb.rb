require_relative "erdb/cli"
require_relative "erdb/version"
require_relative "erdb/utils"
require_relative "erdb/providers/erd_provider"

module ERDB
  autoload :SQL, File.expand_path("erdb/adapters/sql", __dir__)
  autoload :Azimutt, File.expand_path("erdb/providers/azimutt", __dir__)
  autoload :DBDiagram, File.expand_path("erdb/providers/dbdiagram", __dir__)

  class << self
    attr_writer :default_timeout, :default_browser, :show_join_table

    #
    # Default wait time for wait methods.
    # @return [Integer] Default wait time in seconds.
    #
    def default_timeout
      @default_timeout ||= 30
    end

    #
    # Default browser to use for automation.
    # @return [Symbol]
    #
    def default_browser
      @default_browser ||= :chrome
    end

    #
    # Show join table in the diagram.
    # @return [Boolean]
    #
    def show_join_table?
      @show_join_table.nil? ? true : @show_join_table
    end
  end
end
