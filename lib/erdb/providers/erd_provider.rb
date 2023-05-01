module ERDB
  class ERDProvider
    #
    # Create a new ER Diagram.
    # @param [Hash] tables
    #
    def create(tables)
      raise NotImplementedError
    end
  end
end
