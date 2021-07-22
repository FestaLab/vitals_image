# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class Optimizer::UrlTest < ActiveSupport::TestCase
    test "that new images are configured correctly" do
      new_source_with_dimensions(nil, nil) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", image.src

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
      new_source_with_dimensions(100, nil) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", image.src

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
      new_source_with_dimensions(nil, 100) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", image.src

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
      new_source_with_dimensions(100, 100) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", image.src

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
      existing_source_with_dimensions(nil, nil) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/dog.jpg", image.src

        opts = image.html_options
        assert_equal 1401, opts["width"]
        assert_equal 2102, opts["height"]
        assert_equal "height:auto;", opts["style"]
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a width can be chosen for existing images" do
      existing_source_with_dimensions(100, nil) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/dog.jpg", image.src

        opts = image.html_options
        assert_equal 100, opts["width"]
        assert_equal 150, opts["height"]
        assert_equal "height:auto;", opts["style"]
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height can be chosen for existing images" do
      existing_source_with_dimensions(nil, 150) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/dog.jpg", image.src

        opts = image.html_options
        assert_equal 100, opts["width"]
        assert_equal 150, opts["height"]
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height and a width can be chosen for existing images and they will be respected" do
      existing_source_with_dimensions(150, 150) do |image|
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/dog.jpg", image.src

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

    test "that non native lazy loading images are configured correctly" do
      with_non_native_lazy_loading(nil, nil) do |image|
        assert_equal VitalsImage::Base::TINY_GIF, image.src

        opts = image.html_options
        assert_not opts.key?("loading")
        assert_not opts.key?("decoding")
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", opts["data"]["src"]
        assert_equal "lozad vitals-image", opts["class"]
      end
    end

    test "that non native lazy loading images do not override data and class" do
      with_non_native_lazy_loading("my-class", { controller: "my-controller" }) do |image|
        assert_equal VitalsImage::Base::TINY_GIF, image.src

        opts = image.html_options
        assert_not opts.key?("loading")
        assert_not opts.key?("decoding")
        assert_equal "https://festalab-fixtures.s3.amazonaws.com/cat.jpg", opts["data"]["src"]
        assert_equal "my-controller", opts["data"]["controller"]
        assert_equal "lozad vitals-image my-class", opts["class"]
      end
    end

    test "that style is not discarded" do
      new_source_with_dimensions(150, 150, style: "background: #FFF;") do |image|
        opts = image.html_options
        assert_equal "background: #FFF;", opts["style"]
      end

      existing_source_with_dimensions(150, 150, style: "background: #FFF;") do |image|
        opts = image.html_options
        assert_equal "object-fit: contain; background: #FFF;", opts["style"]
      end
    end

    private
      def new_source_with_dimensions(width, height, style: nil)
        url = vitals_image_sources(:cat).key
        yield VitalsImage::Optimizer::Url.new(url, width: width, height: height, style: style)
      end

      def existing_source_with_dimensions(width, height, style: nil)
        url = vitals_image_sources(:dog).key
        yield VitalsImage::Optimizer::Url.new(url, width: width, height: height, style: style)
      end

      def with_non_native_lazy_loading(klass = nil, data = nil)
        VitalsImage.lazy_loading = :lozad

        url = vitals_image_sources(:cat).key
        yield VitalsImage::Optimizer::Url.new(url, class: klass, data: data)
      ensure
        VitalsImage.lazy_loading = :native
      end
  end
end
