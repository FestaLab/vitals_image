# frozen_string_literal: true

module VitalsImage
  class Optimizer::Variable < Optimizer
    def self.accept?(source)
      source.respond_to?(:variable?) && source.variable?
    end

    private
      def source_url
        if analyzed?
          variant
        else
          @source
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

      def analyzed?
        metadata[:analyzed]
      end

      def alpha?
        @options["alpha"]
      end

      def dimensions
        if fixed_dimensions?
          [(requested_width * VitalsImage.resolution).floor, (requested_height * VitalsImage.resolution).floor]
        elsif VitalsImage.resolution * scale > 1
          [original_width, original_height]
        else
          [(width * VitalsImage.resolution).floor, (height * VitalsImage.resolution).floor]
        end
      end

      def resize_mode
        @options[:resize_mode] || @source.metadata["white_background"] ? :resize_and_pad : :resize_to_fill
      end

      def variant
        case (@source.content_type)
        when /jpg|jpeg/
          optimize_jpeg
        when /png/
          optimize_png
        else
          optimize_generic
        end
      end

      def optimize_jpeg
        @source.variant optimizations_with_optimal_quality(VitalsImage.jpeg_optimization)
      end

      def optimize_png
        if alpha? || !VitalsImage.convert_to_jpeg
          @source.variant optimizations(VitalsImage.png_optimization)
        else
          @source.variant optimizations_with_optimal_quality(VitalsImage.jpeg_conversion)
        end
      end

      def optimize_generic
        if alpha? || !VitalsImage.convert_to_jpeg
          @source.variant optimizations
        else
          @source.variant optimizations_with_optimal_quality(VitalsImage.jpeg_conversion)
        end
      end

      def optimizations_with_optimal_quality(defaults = {})
        quality = @source.metadata[:optimal_quality] || defaults[:saver][:quality]
        resize  = resize_mode != :resize_and_pad ? dimensions : dimensions.push(background: [255])

        defaults.deep_merge "#{resize_mode}": resize, saver: { quality: quality }
      end

      def optimizations(defaults = {})
        defaults.merge "#{resize_mode}": dimensions
      end
  end
end
