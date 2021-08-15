# frozen_string_literal: true

require "test_helper"

require "vitals_image/analyzer/url_analyzer"

module VitalsImage
  class Analyzer::UrlAnalyzerTest < ActiveSupport::TestCase
    test "that vips can analyze an url" do
      with_image_library(:vips) do
        Analyzer::UrlAnalyzer.new(vitals_image_sources(:cat)).analyze

        assert_equal 2145, vitals_image_sources(:cat).width
        assert_equal 1430, vitals_image_sources(:cat).height
        assert_equal "image/jpeg", vitals_image_sources(:cat).content_type
        assert vitals_image_sources(:cat).analyzed
      end
    end

    test "that mini_magick can analyze an url" do
      with_image_library(:mini_magick) do
        Analyzer::UrlAnalyzer.new(vitals_image_sources(:cat)).analyze

        assert_equal 2145, vitals_image_sources(:cat).width
        assert_equal 1430, vitals_image_sources(:cat).height
        assert_equal "image/jpeg", vitals_image_sources(:cat).content_type
        assert vitals_image_sources(:cat).analyzed
      end
    end
  end
end
