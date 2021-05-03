# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class AnalyzeJobTest < ActiveJob::TestCase
    test "that the image is analyzed" do
      AnalyzeJob.perform_now(vitals_image_sources(:cat))
      assert vitals_image_sources(:cat).analyzed
    end
  end
end
