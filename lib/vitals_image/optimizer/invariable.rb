# frozen_string_literal: true

module VitalsImage
  class Optimizer::Invariable < Optimizer
    def self.accept?(source)
      source.respond_to?(:variable?) && !source.variable?
    end

    private
      def source_url
        @source
      end

      def style
        if !analyzed?
          # Do nothing
        elsif !requested_height
          "height:auto;"
        elsif fixed_dimensions?
          "object-fit: contain;"
        end
      end

      def original_width
        metadata[:width]
      end

      def original_height
        metadata[:height]
      end

      def metadata
        @source.metadata
      end

      def identified?
        metadata[:identified]
      end

      def analyzed?
        metadata[:analyzed]
      end
  end
end
