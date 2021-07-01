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

  mattr_accessor :transformations
  mattr_accessor :resolution
  mattr_accessor :lazy_loading
  mattr_accessor :lazy_loading_placeholder
  mattr_accessor :check_for_white_background
  mattr_accessor :active_storage_route

  mattr_accessor :skip_ssl_verification
end
