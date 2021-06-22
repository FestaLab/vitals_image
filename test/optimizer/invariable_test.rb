# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class Optimizer::InvariableTest < ActiveSupport::TestCase
    test "that new images are configured correctly" do
      new_source_with_dimensions(nil, nil) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_not opts.key?("width")
        assert_not opts.key?("height")
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a width can be chosen for new images" do
      new_source_with_dimensions(100, nil) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 100, opts["width"]
        assert_not opts.key?("height")
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height can be chosen for new images" do
      new_source_with_dimensions(nil, 100) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_not opts.key?("width")
        assert_equal 100, opts["height"]
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height and a width can be chosen for new images" do
      new_source_with_dimensions(100, 100) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 100, opts["width"]
        assert_equal 100, opts["height"]
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that existing images are configured correctly" do
      existing_source_with_dimensions(nil, nil) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 400, opts["width"]
        assert_equal 500, opts["height"]
        assert_equal "height:auto;", opts["style"]
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a width can be chosen for existing images" do
      existing_source_with_dimensions(100, nil) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 100, opts["width"]
        assert_equal 125, opts["height"]
        assert_equal "height:auto;", opts["style"]
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height can be chosen for existing images" do
      existing_source_with_dimensions(nil, 150) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 120, opts["width"]
        assert_equal 150, opts["height"]
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height and a width can be chosen for existing images and they will be respected" do
      existing_source_with_dimensions(150, 150) do |image, blob|
        assert_equal blob, image.src

        opts = image.html_options
        assert_equal 150, opts["width"]
        assert_equal 150, opts["height"]
        assert_equal "object-fit: contain;", opts["style"]
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    private
      def new_source_with_dimensions(width, height)
        blob = create_file_blob(filename: "icon.svg", content_type: "image/svg+xml")
        yield VitalsImage::Optimizer::Invariable.new(blob, width: width, height: height), blob
      end

      def existing_source_with_dimensions(width, height)
        blob = create_file_blob(filename: "icon.svg", content_type: "image/svg+xml", metadata: { analyzed: true, width: 400, height: 500 })
        yield VitalsImage::Optimizer::Invariable.new(blob, width: width, height: height), blob
      end
  end
end
