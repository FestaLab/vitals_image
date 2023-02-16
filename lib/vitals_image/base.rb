# frozen_string_literal: true

module VitalsImage
  class Base
    TINY_GIF = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7".freeze

    def self.optimizer(object, options = {})
      klass = VitalsImage.optimizers.detect { |optimizer| optimizer.accept?(object) }
      raise UnoptimizableError, "Object is not supported: #{object.class}" unless klass

      klass.new(object, options)
    end

    def self.analyzer(object)
      klass = VitalsImage.analyzers.detect { |analyzer| analyzer.accept?(object) }
      raise UnanalyzableError, "Object is not supported: #{object.class}" unless klass

      klass.new(object)
    end
  end
end
