require_relative "erdb/cli"
require_relative "erdb/version"
require_relative "erdb/utils"

module ERDB
  autoload :SQL, File.expand_path("erdb/adapters/sql", __dir__)
  autoload :Azimutt, File.expand_path("erdb/providers/azimutt", __dir__)
  autoload :DBDiagram, File.expand_path("erdb/providers/dbdiagram", __dir__)

  class << self
    attr_writer :default_timeout, :default_browser, :hide_join_table

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
    # Hide join table from the diagram.
    # @return [Boolean]
    #
    def hide_join_table?
      @hide_join_table ||= false
    end
  end
end
