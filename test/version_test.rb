# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class VersionTest < ActiveSupport::TestCase
    test "that version is set" do
      assert VitalsImage::VERSION
    end
  end
end
