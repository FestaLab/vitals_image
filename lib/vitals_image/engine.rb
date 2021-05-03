# frozen_string_literal: true

require "active_job"
require "active_model"
require "active_record"
require "active_storage"
require "active_support"

require "marcel"
require "ruby-vips"
require "mini_magick"

require "vitals_image/analyzer"
require "vitals_image/analyzer/url"
require "vitals_image/base"
require "vitals_image/cache"
require "vitals_image/errors"
require "vitals_image/optimizer"
require "vitals_image/optimizer/blank"
require "vitals_image/optimizer/url"
require "vitals_image/optimizer/active_storage"

module VitalsImage
  class Engine < ::Rails::Engine
    isolate_namespace VitalsImage

    config.vitals_image                                 = ActiveSupport::OrderedOptions.new
    config.vitals_image.optimizers                      = [VitalsImage::Optimizer::Blank, VitalsImage::Optimizer::ActiveStorage, VitalsImage::Optimizer::Url]
    config.vitals_image.analyzers                       = [VitalsImage::Analyzer::Url]

    config.eager_load_namespaces << VitalsImage

    initializer "vitals_image.configs" do
      config.after_initialize do |app|
        VitalsImage.logger                          = app.config.vitals_image.logger || Rails.logger
        VitalsImage.optimizers                      = app.config.vitals_image.optimizers || []
        VitalsImage.analyzers                       = app.config.vitals_image.analyzers || []
        VitalsImage.image_library                   = app.config.vitals_image.image_library || :mini_magick

        VitalsImage.mobile_width                    = app.config.vitals_image.mobile_width || :original
        VitalsImage.desktop_width                   = app.config.vitals_image.desktop_width || :original
        VitalsImage.resolution                      = app.config.vitals_image.resolution || 2
        VitalsImage.lazy_loading                    = app.config.vitals_image.lazy_loading || :native
        VitalsImage.lazy_loading_placeholder        = app.config.vitals_image.lazy_loading_placeholder || VitalsImage::Base::TINY_GIF
        VitalsImage.require_alt_attribute           = app.config.vitals_image.require_alt_attribute || false

        VitalsImage.replace_active_storage_analyzer = app.config.vitals_image.replace_active_storage_analyzer || false
        VitalsImage.check_for_white_background      = app.config.vitals_image.check_for_white_background || false

        VitalsImage.convert_to_jpeg                 = app.config.vitals_image.convert_to_jpeg || false
        VitalsImage.jpeg_conversion                 = app.config.vitals_image.jpeg_conversion || { sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80, format: "jpg", background: :white, flatten: true, alpha: :off }
        VitalsImage.jpeg_optimization               = app.config.vitals_image.jpeg_optimization || { sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80 }
        VitalsImage.png_optimization                = app.config.vitals_image.png_optimization || { strip: true, quality: 00 }
        VitalsImage.active_storage_route            = app.config.vitals_image.png_optimization || :inherited
      end
    end

    initializer "vitals_image.core_extensions" do
      require_relative "core_extensions/active_storage/image_analyzer"
      require_relative "core_extensions/active_storage/isolated_image_analyzer"

      config.after_initialize do |app|
        if VitalsImage.check_for_white_background
          app.config.active_storage.analyzers.delete ActiveStorage::Analyzer::ImageAnalyzer
          app.config.active_storage.analyzers.prepend CoreExtensions::ActiveStorage::IsolatedImageAnalyzer
        elsif VitalsImage.replace_active_storage_analyzer
          app.config.active_storage.analyzers.delete ActiveStorage::Analyzer::ImageAnalyzer
          app.config.active_storage.analyzers.prepend CoreExtensions::ActiveStorage::ImageAnalyzer
        end
      end
    end

    initializer "vitals_image.action_controller" do
      ActiveSupport.on_load :action_controller do
        helper VitalsImage::TagHelper
      end
    end
  end
end
