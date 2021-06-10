# frozen_string_literal: true

require "test_helper"

module VitalsImage
  module CoreExtensions
    module ActiveStorage
      class ImageAnalyzerTest < ActiveSupport::TestCase
        test "that image is analyzed" do
          blob = create_file_blob(filename: "bird.jpg", content_type: "image/jpg")
          metadata = CoreExtensions::ActiveStorage::ImageAnalyzer.new(blob).metadata

          assert_equal 2000, metadata[:width]
          assert_equal 1333, metadata[:height]
          assert_not metadata[:isolated]
        end
        
        test "that an isolated product is detected" do
          blob = create_file_blob(filename: "invalid.jpg", content_type: "image/jpg")
          metadata = CoreExtensions::ActiveStorage::ImageAnalyzer.new(blob).metadata

          assert_nil metadata[:width]
          assert_nil metadata[:height]
        end
      end
    end
  end
end
