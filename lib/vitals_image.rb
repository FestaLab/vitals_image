# frozen_string_literal: true

require "vitals_image/version"
require "vitals_image/engine"

module VitalsImage
  extend ActiveSupport::Autoload

  autoload :FixtureSet


  mattr_accessor :logger
  mattr_accessor :optimizers
  mattr_accessor :analyzers
  mattr_accessor :image_library

  mattr_accessor :mobile_width
  mattr_accessor :desktop_width
  mattr_accessor :resolution
  mattr_accessor :lazy_loading
  mattr_accessor :lazy_loading_placeholder
  mattr_accessor :require_alt_attribute

  mattr_accessor :replace_active_storage_analyzer
  mattr_accessor :check_for_white_background

  mattr_accessor :convert_to_jpeg
  mattr_accessor :jpeg_conversion
  mattr_accessor :jpeg_optimization
  mattr_accessor :png_optimization
  mattr_accessor :active_storage_route
end
