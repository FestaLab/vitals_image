# frozen_string_literal: true

module VitalsImage
  class Optimizer::Blank < Optimizer
    def self.accept?(source)
      source.blank?
    end

    private
      def source_url
        VitalsImage.lazy_loading_placeholder
      end

      def width
        @options["width"]
      end

      def height
        @options["height"]
      end

      def style
        nil
      end

      def lazy_load?
        false
      end
  end
end
