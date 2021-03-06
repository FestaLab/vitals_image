# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class Optimizer::VariableTest < ActiveSupport::TestCase
    test "that new images are configured correctly" do
      new_jpeg_with_dimensions(nil, nil) do |image, blob|
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

    test "that width can be chosen for new images" do
      new_jpeg_with_dimensions(100, nil) do |image, blob|
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

    test "that height can be chosen for new images" do
      new_jpeg_with_dimensions(nil, 100) do |image, blob|
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

    test "that height and width can be chosen for new images" do
      new_jpeg_with_dimensions(100, 100) do |image, blob|
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
      existing_jpeg_with_dimensions(nil, nil) do |image|
        assert_equal [1401, 2102], image.src.variation.transformations[:resize_to_fill]

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
      existing_jpeg_with_dimensions(100, nil) do |image|
        assert_equal [200, 300], image.src.variation.transformations[:resize_to_fill]

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
      existing_jpeg_with_dimensions(nil, 150) do |image|
        assert_equal [200, 300], image.src.variation.transformations[:resize_to_fill]

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
      existing_jpeg_with_dimensions(150, 150) do |image|
        assert_equal [300, 300], image.src.variation.transformations[:resize_to_fill]

        opts = image.html_options
        assert_equal 150, opts["width"]
        assert_equal 150, opts["height"]
        assert_not opts.key?("style")
        assert_equal "lazy", opts["loading"]
        assert_equal "async", opts["decoding"]
        assert_not opts.key?("data")
        assert_equal "vitals-image", opts["class"]
      end
    end

    test "that a height and width can be chosen for an existing image of an object in a white background and it will be padded" do
      with_image_library(:mini_magick) do
        existing_jpeg_with_dimensions(150, 150, white_background: true) do |image|
          assert_equal [300, 300], image.src.variation.transformations[:resize_and_pad]
        end
      end

      with_image_library(:vips) do
        existing_jpeg_with_dimensions(150, 150, white_background: true) do |image|
          assert_equal [300, 300, background: [255]], image.src.variation.transformations[:resize_and_pad]
        end
      end
    end

    test "that optimizer will not attempt to upscale the image to match specified width and resolution" do
      existing_jpeg_with_dimensions(1000, nil) do |image|
        assert_equal [1401, 2102], image.src.variation.transformations[:resize_to_fill]
      end
    end

    test "that png image is converted" do
      with_jpeg_conversion_set_to(true) do
        blob = create_file_blob(filename: "invitation.png", content_type: "image/png", metadata: { analyzed: true, width: 800, height: 1200 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 800)

        assert_equal [800, 1200], image.src.variation.transformations[:resize_to_fill]
        assert_equal "jpg", image.src.variation.transformations[:format]
      end
    end

    test "that png image is not converted if alpha is specified" do
      with_jpeg_conversion_set_to(true) do
        blob = create_file_blob(filename: "invitation.png", content_type: "image/png", metadata: { analyzed: true, width: 800, height: 1200 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 800, alpha: true)

        assert_equal [800, 1200], image.src.variation.transformations[:resize_to_fill]
        assert_equal "png", image.src.variation.transformations[:format]
      end
    end

    test "that png image is not converted if the feature was disabled" do
      with_jpeg_conversion_set_to(false) do
        blob = create_file_blob(filename: "invitation.png", content_type: "image/png", metadata: { analyzed: true, width: 800, height: 1200 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 800)

        assert_equal [800, 1200], image.src.variation.transformations[:resize_to_fill]
        assert_equal "png", image.src.variation.transformations[:format]
      end
    end

    test "that generic image is converted" do
      with_jpeg_conversion_set_to(true) do
        blob = create_file_blob(filename: "dog.webp", content_type: "image/webp", metadata: { analyzed: true, width: 1401, height: 2102 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 100)

        assert_equal [200, 300], image.src.variation.transformations[:resize_to_fill]
        assert_equal "jpg", image.src.variation.transformations[:format]
      end
    end

    test "that generic image is not converted if alpha is specified" do
      with_jpeg_conversion_set_to(true) do
        blob = create_file_blob(filename: "dog.webp", content_type: "image/webp", metadata: { analyzed: true, width: 1401, height: 2102 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 100, alpha: true)

        assert_equal [200, 300], image.src.variation.transformations[:resize_to_fill]
        assert_not_equal "jpg", image.src.variation.transformations[:format]
      end
    end

    test "that generic image is not converted if the feature was disabled" do
      with_jpeg_conversion_set_to(false) do
        blob = create_file_blob(filename: "dog.webp", content_type: "image/webp", metadata: { analyzed: true, width: 1401, height: 2102 })
        image = VitalsImage::Optimizer::Variable.new(blob, width: 100)

        assert_equal [200, 300], image.src.variation.transformations[:resize_to_fill]
        assert_not_equal "jpg", image.src.variation.transformations[:format]
      end
    end

    test "that source that have not been analyzed are not transformed" do
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: false })
      assert_equal blob, VitalsImage::Optimizer::Variable.new(blob, width: 100).src
    end

    test "that resize mode is respected" do
      # White Background
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: true, width: 1401, height: 2102, white_background: :white_background })
      image = VitalsImage::Optimizer::Variable.new(blob, width: 300, height: 300)
      assert_equal :resize_and_pad, image.send(:resize_mode)

      # White Background defining resize method
      image = VitalsImage::Optimizer::Variable.new(blob, width: 300, height: 300, resize_mode: :resize_to_fit)
      assert_equal :resize_to_fit, image.send(:resize_mode)

      # Non-white Background
      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: true, width: 1401, height: 2102 })
      image = VitalsImage::Optimizer::Variable.new(blob, width: 300, height: 300)
      assert_equal :resize_to_fill, image.send(:resize_mode)
    end

    private
      def new_jpeg_with_dimensions(width, height)
        blob = create_file_blob(filename: "cat.jpg", content_type: "image/jpg")
        yield VitalsImage::Optimizer::Variable.new(blob, width: width, height: height), blob
      end

      def existing_jpeg_with_dimensions(width, height, white_background: false)
        blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: true, width: 1401, height: 2102, white_background: white_background })
        yield VitalsImage::Optimizer::Variable.new(blob, width: width, height: height)
      end

      def with_jpeg_conversion_set_to(value)
        previous_option = VitalsImage.convert_to_jpeg
        VitalsImage.convert_to_jpeg = value

        yield
      ensure
        VitalsImage.convert_to_jpeg = previous_option
      end
  end
end
