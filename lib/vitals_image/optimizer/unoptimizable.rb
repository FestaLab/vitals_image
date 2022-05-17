# frozen_string_literal: true

module VitalsImage
  class Optimizer::Unoptimizable < Optimizer
    def self.accept?(source)
      true
    end

    private
      def source_url
        @source
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
  end
end
