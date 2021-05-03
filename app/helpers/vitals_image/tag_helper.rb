# frozen_string_literal: true

module VitalsImage
  module TagHelper
    def vitals_image_tag(source, options = {})
      source = image_url(source) if source.is_a?(String)
      optimizer = VitalsImage::Base.optimizer(source, options)

      if !optimizer.variable?
        vitals_image_invariable_tag(optimizer)
      elsif optimizer.native_lazy_load?
        vitals_image_variable_tag(optimizer)
      else
        vitals_image_lazy_tag(optimizer)
      end
    end

    private
      def vitals_image_invariable_tag(optimizer)
        image_tag optimizer.src, optimizer.html_options
      end

      def vitals_image_variable_tag(optimizer)
        url = vitals_image_url(optimizer.src, optimizer.html_options)
        image_tag url, optimizer.html_options
      end

      def vitals_image_lazy_tag(optimizer)
        url = vitals_image_url(optimizer.html_options["data"]["src"], optimizer.html_options)
        optimizer.html_options["data"]["src"] = url

        image_tag optimizer.src, optimizer.html_options
      end

      def vitals_image_url(source, options)
        active_storage_route = options.delete("active_storage_route") || VitalsImage.active_storage_route

        case active_storage_route
        when :redirect
          rails_storage_redirect_path(source)
        when :proxy
          rails_storage_proxy_path(source)
        when :public
          source.is_a?(ActiveStorage::VariantWithRecord) ? source.processed.url : source.url
        else
          url_for(source)
        end
      end
  end
end
