# frozen_string_literal: true

module VitalsImage
  module TagHelper
    def vitals_image_tag(source, options = {})
      source = image_url(source) if source.is_a?(String)
      optimizer = VitalsImage::Base.optimizer(source, options)

      if optimizer.non_native_lazy_load?
        url = vitals_image_url(optimizer.html_options["data"]["src"], optimizer.html_options)
        optimizer.html_options["data"]["src"] = url
        image_tag optimizer.src, optimizer.html_options
      else
        url = vitals_image_url(optimizer.src, optimizer.html_options)
        image_tag url, optimizer.html_options
      end
    rescue StandardError => error
      Sentry.capture_exception(error) if Rails.env.production?
      image_tag Base::TINY_GIF
    end

    def vitals_image_url(source, options = {})
      active_storage_route = options.delete("active_storage_route") || options.delete(:active_storage_route) || VitalsImage.active_storage_route
      return source.url if source.is_a?(VitalsImage::TinyGif)

      case active_storage_route
      when :redirect
        rails_storage_redirect_path(source)
      when :proxy
        rails_storage_proxy_path(source)
      when :public
        public_url_for(source)
      else
        url_for(source)
      end
    end

    private
      def public_url_for(source)
        if source.is_a?(String) || Rails.application.config.active_storage.service =~ /(local|test)/
          url_for(source)
        elsif source.is_a?(ActiveStorage::VariantWithRecord)
          source.processed.url
        else
          source.url
        end
      end
  end
end
