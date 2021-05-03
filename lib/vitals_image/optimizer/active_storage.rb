# frozen_string_literal: true

module VitalsImage
  class Optimizer::ActiveStorage < Optimizer
    def self.accept?(source)
      source.is_a?(::ActiveStorage::Attached) || source.is_a?(::ActiveStorage::Attachment) || source.is_a?(::ActiveStorage::Blob)
    end

    def variable?
      true
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
        @options[:resize_mode] || @source.metadata["isolated"] ? :resize_and_pad : :resize_to_fill
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
        @source.variant VitalsImage.jpeg_optimization.merge("#{resize_mode}": dimensions)
      end

      def optimize_png
        if alpha? || !VitalsImage.convert_to_jpeg
          @source.variant VitalsImage.png_optimization.merge("#{resize_mode}": dimensions)
        else
          @source.variant VitalsImage.jpeg_conversion.merge("#{resize_mode}": dimensions)
        end
      end

      def optimize_generic
        if alpha? || !VitalsImage.convert_to_jpeg
          @source.variant("#{resize_mode}": dimensions)
        else
          @source.variant VitalsImage.jpeg_conversion.merge("#{resize_mode}": dimensions)
        end
      end
  end
end
