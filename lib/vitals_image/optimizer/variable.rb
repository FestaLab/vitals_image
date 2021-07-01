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
        format  = @source.content_type.split("/").last.to_sym
        optimal = @source.metadata[:optimal_quality]
        library = VitalsImage.image_library

        transformations = VitalsImage.transformations[format][library] || { saver: {} }
        transformations["#{resize_mode}"] = dimensions
        transformations[:saver][:quality] = optimal if optimal

        @source.variant(transformations)
      end
  end
end
