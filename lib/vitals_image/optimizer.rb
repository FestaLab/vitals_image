# frozen_string_literal: true

module VitalsImage
  # This is an abstract base class for optimizers
  class Optimizer
    # Implement this method in a concrete subclass. Have it return true when given a source from which
    # it can calculate dimensions
    def self.accept?(source)
      false
    end

    def initialize(source, options = {})
      @source = source
      @options = options.deep_stringify_keys

      raise ArgumentError, "You must specify an alt for your image" if @options["alt"].blank? && VitalsImage.require_alt_attribute
    end

    def src
      if non_native_lazy_load?
        VitalsImage.lazy_loading_placeholder
      else
        source_url
      end
    end

    def html_options
      @html_options ||= begin
        html_options = @options.dup
        html_options["width"]           = width
        html_options["height"]          = height
        html_options["style"]           = style
        html_options["class"]           = "vitals-image #{html_options["class"]}".squish

        if non_native_lazy_load?
          html_options["class"]         = "#{VitalsImage.lazy_loading} #{html_options["class"]}".squish
          html_options["data"]        ||= {}
          html_options["data"]["src"]   = source_url
        elsif lazy_load?
          html_options["loading"]       = "lazy"
          html_options["decoding"]      = "async"
        end

        html_options.compact
      end
    end

    def lazy_load?
      @options["lazy_load"] != false && VitalsImage.lazy_loading
    end

    def non_native_lazy_load?
      lazy_load? && VitalsImage.lazy_loading != :native
    end

    def native_lazy_load?
      lazy_load? && VitalsImage.lazy_loading == :native
    end

    # Override this method in a concrete subclass. Have it return true the source is an active storage blob
    def variable?
      false
    end

    private
      def style
        if analyzed? && !requested_height
          "height:auto;"
        end
      end

      def width
        if !analyzed? || fixed_dimensions?
          requested_width
        else
          (original_width * scale).round
        end
      end

      def height
        if !analyzed? || fixed_dimensions?
          requested_height
        else
          (original_height * scale).round
        end
      end


      def scale
        [scale_x, scale_y].min
      end

      def scale_x
        requested_width ? requested_width.to_f / original_width : 1.0
      end

      def scale_y
        requested_height ? requested_height.to_f / original_height : 1.0
      end

      def fixed_dimensions?
        requested_width && requested_height
      end

      def requested_width
        @options["width"]
      end

      def requested_height
        @options["height"]
      end


      # Override this method in a concrete subclass. Have it return true if width and height are available
      def analyzed?
        raise NotImplementedError
      end

      # Override this method in a concrete subclass. Have it return the width of the image
      def original_width
        raise NotImplementedError
      end

      # Override this method in a concrete subclass. Have it return the height of the image
      def original_height
        raise NotImplementedError
      end


      # Override this method in a concrete subclass. Have it return the url of the image
      def source_url
        raise NotImplementedError
      end
  end
end
