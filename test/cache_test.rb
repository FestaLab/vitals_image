# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class CacheTest < ActiveSupport::TestCase
    test "that cache is a singleton" do
      assert_raise NoMethodError do
        VitalsImage::Cache.new
      end
    end

    test "that cache can locate a new source" do
      assert_difference("Source.count", 1) do
        source = VitalsImage::Cache.instance.locate("https://festalab-fixtures.s3.amazonaws.com/bird.jpg")
        assert_not source.analyzed
      end
    end

    test "that cache can locate an existing source" do
      assert_no_difference("Source.count") do
        source = VitalsImage::Cache.instance.locate("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
        assert_equal vitals_image_sources(:dog), source
      end
    end

    test "that keeps sources in memory" do
      VitalsImage::Cache.instance.locate("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
      vitals_image_sources(:dog).update_attribute :width, 1

      source = VitalsImage::Cache.instance.locate("https://festalab-fixtures.s3.amazonaws.com/dog.jpg")
      assert_equal 1401, source.width
    end
  end
end
