# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class SourceTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "that fixtures are valid" do
      assert vitals_image_sources.all?(&:valid?)
    end

    test "that key must be unique in the database" do
      assert_raise ActiveRecord::RecordNotUnique do
        VitalsImage::Source.create! key: vitals_image_sources(:dog).key
      end
    end

    test "that analyze job is enqueued after a record is created" do
      assert_enqueued_jobs 1 do
        VitalsImage::Source.create! key: "www.example.com"
      end
    end
  end
end
