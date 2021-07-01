# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class OptimizerTest < ActiveSupport::TestCase
    test "that lazy load can be disabled" do
      assert_not VitalsImage::Optimizer.new(nil, lazy_load: false).send(:lazy_load?)
    end
  end
end
