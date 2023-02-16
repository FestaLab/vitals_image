# frozen_string_literal: true

require "test_helper"

module VitalsImage
  class TinyGifTest < ActiveSupport::TestCase
    test "processed url" do
      gif = TinyGif.instance
      assert_equal Base::TINY_GIF, gif.processed.url
    end
  end
end
