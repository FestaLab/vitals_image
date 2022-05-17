# frozen_string_literal: true

module VitalsImage
  # Generic base class for all VitalsImage exceptions.
  class Error < StandardError; end

  # Raised when VitalsImage is given a source it cannot extract metadata from
  class UnanalyzableError < Error; end

  # Raised when VitalsImage is given a url that it cannot download a file from
  class FileNotFoundError < Error; end
end
