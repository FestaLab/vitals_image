# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class ImageAnalyzerTest < ActiveSupport::TestCase
    test "that image is analyzed" do
      blob = create_file_blob(filename: "bird.jpg", content_type: "image/jpg")
      metadata = Analyzer::ImageAnalyzer.new(blob).metadata

      assert_equal 2000, metadata[:width]
      assert_equal 1333, metadata[:height]
    end

    test "that an unsupported image is detected" do
      blob = create_file_blob(filename: "invalid.jpg", content_type: "image/jpg")
      metadata = Analyzer::ImageAnalyzer.new(blob).metadata

      assert_not metadata[:isolated]
    end
  end
end
