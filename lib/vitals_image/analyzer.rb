# frozen_string_literal: true

module VitalsImage
  # This is an abstract base class for dimension calculators
  class Analyzer
    attr_reader :source

    # Implement this method in a concrete subclass. Have it return true when given a source from which
    # it can calculate dimensions
    def self.accept?(source)
      false
    end

    def initialize(source)
      @source = source
    end

    def logger
      VitalsImage.logger
    end
  end
end
