# frozen_string_literal: true

require "active_support/test_case"

module VitalsImage
  class TestCase < ActiveSupport::TestCase
    include ViewComponent::TestHelpers
  end
end
