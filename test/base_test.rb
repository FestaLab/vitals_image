# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class BaseTest < ActiveSupport::TestCase
    test "that the correct optimizer is chosen" do
      assert VitalsImage::Base.optimizer(nil).is_a?(VitalsImage::Optimizer::Blank)
      assert VitalsImage::Base.optimizer("").is_a?(VitalsImage::Optimizer::Blank)

      assert VitalsImage::Base.optimizer("http://www.example.com").is_a?(VitalsImage::Optimizer::Url)
      assert VitalsImage::Base.optimizer("https://festalab-fixtures.s3.amazonaws.com/cat.jpg").is_a?(VitalsImage::Optimizer::Url)

      blob = create_file_blob(filename: "dog.jpg", content_type: "image/jpg", metadata: { analyzed: true, width: 100, height: 100 })
      assert VitalsImage::Base.optimizer(blob).is_a?(VitalsImage::Optimizer::Variable)

      blob = create_file_blob(filename: "icon.svg", content_type: "image/svg+xml", metadata: { analyzed: true, width: 100, height: 100 })
      assert VitalsImage::Base.optimizer(blob).is_a?(VitalsImage::Optimizer::Invariable)
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
