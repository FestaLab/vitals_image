# frozen_string_literal: true

require_relative "../../app/models/vitals_image/source"

module VitalsImage
  class Cache
    include Singleton

    def initialize
      @store = ActiveSupport::Cache::MemoryStore.new
    end

    def locate(key)
      with_retry do
        source = @store.read(key)

        if source.blank?
          source = Source.find_or_create_by(key: key)
          expires_in = source.analyzed ? nil : 1.minute
          @store.write(key, source, expires_in: expires_in)
        end

        source
      end
    end

    private
      def with_retry
        yield
      rescue ActiveRecord::RecordNotUnique
        yield
      end
  end
end
