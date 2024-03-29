# frozen_string_literal: true

require "active_job"
require "active_model"
require "active_record"
require "active_storage"
require "active_support"

require "marcel"
require "ruby-vips"
require "mini_magick"
require "active_analysis"

require "vitals_image/analyzer"
require "vitals_image/analyzer/url_analyzer"
require "vitals_image/base"
require "vitals_image/cache"
require "vitals_image/errors"
require "vitals_image/optimizer"
require "vitals_image/optimizer/blank"
require "vitals_image/optimizer/url"
require "vitals_image/optimizer/variable"
require "vitals_image/optimizer/invariable"
require "vitals_image/optimizer/unoptimizable"
require "vitals_image/tiny_gif"

module VitalsImage
  class Engine < ::Rails::Engine
    isolate_namespace VitalsImage

    config.vitals_image                                 = ActiveSupport::OrderedOptions.new
    config.vitals_image.optimizers                      = [VitalsImage::Optimizer::Blank, VitalsImage::Optimizer::Variable, VitalsImage::Optimizer::Invariable, VitalsImage::Optimizer::Url, VitalsImage::Optimizer::Unoptimizable]
    config.vitals_image.analyzers                       = [VitalsImage::Analyzer::UrlAnalyzer]
    config.vitals_image.domains                         = []

    config.eager_load_namespaces << VitalsImage

    initializer "vitals_image.configs" do
      config.after_initialize do |app|
        VitalsImage.image_library              = app.config.active_storage.variant_processor        || :mini_magick

        VitalsImage.logger                     = app.config.vitals_image.logger                     || Rails.logger
        VitalsImage.optimizers                 = app.config.vitals_image.optimizers                 || []
        VitalsImage.analyzers                  = app.config.vitals_image.analyzers                  || []

        VitalsImage.resolution                 = app.config.vitals_image.resolution                 || 2
        VitalsImage.lazy_loading               = app.config.vitals_image.lazy_loading               || :native
        VitalsImage.lazy_loading_placeholder   = app.config.vitals_image.lazy_loading_placeholder   || VitalsImage::Base::TINY_GIF
        VitalsImage.require_alt_attribute      = app.config.vitals_image.require_alt_attribute      || false

        VitalsImage.check_for_white_background = app.config.vitals_image.check_for_white_background || false

        VitalsImage.active_storage_route       = app.config.vitals_image.active_storage_route       || :inherited
        VitalsImage.convert_to_jpeg            = app.config.vitals_image.convert_to_jpeg            || false
        VitalsImage.jpeg_conversion            = app.config.vitals_image.jpeg_conversion
        VitalsImage.jpeg_optimization          = app.config.vitals_image.jpeg_optimization
        VitalsImage.png_optimization           = app.config.vitals_image.png_optimization
        VitalsImage.webp_conversion            = app.config.vitals_image.webp_conversion
        VitalsImage.domains                    = app.config.vitals_image.domains                    || []

        VitalsImage.skip_ssl_verification      = app.config.vitals_image.skip_ssl_verification      || false
      end
    end

    initializer "vitals_image.analyzers" do
      config.after_initialize do |app|
        if VitalsImage.check_for_white_background
          app.config.active_analysis.addons << ActiveAnalysis::Addon::ImageAddon::WhiteBackground
        end
      end
    end

    initializer "vitals_image.optimizations" do
      config.after_initialize do |app|
        if VitalsImage.image_library == :vips
          VitalsImage.jpeg_conversion   ||= { saver: { strip: true, quality: 80, interlace: true, optimize_coding: true, trellis_quant: true, quant_table: 3, background: 255 }, format: "jpg" }
          VitalsImage.jpeg_optimization ||= { saver: { strip: true, quality: 80, interlace: true, optimize_coding: true, trellis_quant: true, quant_table: 3 }, format: "jpg" }
          VitalsImage.png_optimization  ||= { saver: { strip: true, compression: 9 } }
          VitalsImage.webp_conversion   ||= { saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true }, format: "webp" }
        else
          VitalsImage.jpeg_conversion   ||= { saver: { strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB", background: :white, flatten: true, alpha: :off }, format: "jpg" }
          VitalsImage.jpeg_optimization ||= { saver: { strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB" }, format: "jpg" }
          VitalsImage.png_optimization  ||= { saver: { strip: true, quality: 75 } }
          VitalsImage.webp_conversion   ||= { saver: { strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } } }, format: "webp" }
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
