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

    test "that only sources that were not analyzed expire in in minute in the cache" do
      cat = vitals_image_sources(:cat).key
      dog = vitals_image_sources(:dog).key

      VitalsImage::Cache.instance.locate(cat)
      VitalsImage::Cache.instance.locate(dog)

      data = VitalsImage::Cache.instance.instance_variable_get(:@store).instance_variable_get(:@data)

      assert Time.at(data[cat].expires_at) < Time.now + 61.seconds
      assert_nil data[dog].expires_at
    end

    test "that only sources from allowed domains will be analyzed" do
      VitalsImage.domains = ["festalab.com.br"]

      assert_no_difference("VitalsImage::Source.count") do
        source = Cache.instance.locate("https://joliz.com.br/bird.jpg")
        assert_not source.metadata["identified"]
      end

      assert_difference("VitalsImage::Source.count", 1) do
        source = Cache.instance.locate("https://festalab.com.br/fish.jpg")
        assert source.metadata["identified"]
      end
    ensure
      VitalsImage.domains = []
    end
  end
end
