# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class OptimizerTest < ActiveSupport::TestCase
    test "that an exception is raised only if alt is missing and it was configured as required" do
      assert_nothing_raised do
        VitalsImage::Optimizer.new(nil)
      end

      VitalsImage.require_alt_attribute = true

      assert_raise ArgumentError do
        VitalsImage::Optimizer.new(nil)
      end

      VitalsImage.require_alt_attribute = false
    end

    test "that lazy load can be disabled" do
      assert_not VitalsImage::Optimizer.new(nil, lazy_load: false).send(:lazy_load?)
    end
  end
end
