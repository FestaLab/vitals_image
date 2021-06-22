# frozen_string_literal: true

require "test_helper"

class VitalsImage::Optimizer::BlankTest < ActiveSupport::TestCase
  test "that blank images are configured correctly" do
    with_dimensions(nil, nil) do |image|
      assert_equal VitalsImage.lazy_loading_placeholder, image.src

      opts = image.html_options
      assert_not opts.key?("width")
      assert_not opts.key?("height")
      assert_not opts.key?("style")
      assert_not opts.key?("loading")
      assert_not opts.key?("decoding")
      assert_not opts.key?("data")
      assert_equal "vitals-image", opts["class"]
    end
  end

  test "that dimensions can be defined" do
    with_dimensions(100, 200) do |image|
      opts = image.html_options
      assert_equal 100, opts["width"]
      assert_equal 200, opts["height"]
    end
  end

  private
    def with_dimensions(width, height)
      yield VitalsImage::Optimizer::Blank.new(nil, width: width, height: height)
    end
end
