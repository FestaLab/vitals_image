# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class BaseTest < ActiveSupport::TestCase
    test "that the correct optimizer is chosen" do
      assert VitalsImage::Base.optimizer(nil).is_a?(VitalsImage::Optimizer::Blank)
      assert VitalsImage::Base.optimizer("").is_a?(VitalsImage::Optimizer::Blank)

      assert VitalsImage::Base.optimizer("http://www.example.com").is_a?(VitalsImage::Optimizer::Url)
      assert VitalsImage::Base.optimizer("https://festalab-fixtures.s3.amazonaws.com/cat.jpg").is_a?(VitalsImage::Optimizer::Url)

      assert VitalsImage::Base.optimizer(ActiveStorage::Attachment.new).is_a?(VitalsImage::Optimizer::ActiveStorage)
      assert VitalsImage::Base.optimizer(ActiveStorage::Attached.new(nil, nil)).is_a?(VitalsImage::Optimizer::ActiveStorage)
      assert VitalsImage::Base.optimizer(ActiveStorage::Blob.new).is_a?(VitalsImage::Optimizer::ActiveStorage)
    end

    test "that an exception is raised if no optimizers are available for the specified source" do
      assert_raise VitalsImage::UnoptimizableError do
        VitalsImage::Base.optimizer("/some-asset.svg")
      end
    end

    test "that the correct analyzer is chosen" do
      assert VitalsImage::Base.analyzer(vitals_image_sources(:cat)).is_a?(VitalsImage::Analyzer::UrlAnalyzer)
    end

    test "that an exception is raised if no analyzers are available for the specified source" do
      assert_raise VitalsImage::UnanalyzableError do
        VitalsImage::Base.analyzer("/some-asset.svg")
      end
    end
  end
end
