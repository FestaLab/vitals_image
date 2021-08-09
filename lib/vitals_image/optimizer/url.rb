# frozen_string_literal: true

module VitalsImage
  class Optimizer::Url < Optimizer
    def self.accept?(source)
      uri = URI.parse(source)
      %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
    end

    private
      def source_url
        @source
      end

      def style
        if !identified? || !analyzed?
          # Do nothing
        elsif !requested_height
          "height:auto;"
        elsif fixed_dimensions?
          "object-fit: contain;"
        end
      end

      def identified?
        metadata.identified
      end

      def analyzed?
        metadata.analyzed
      end

      def original_width
        metadata.width
      end

      def original_height
        metadata.height
      end

      def metadata
        Cache.instance.locate(@source)
      end
  end
end
