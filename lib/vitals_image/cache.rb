# frozen_string_literal: true

module VitalsImage
  class Cache
    include Singleton

    def initialize
      @store = ActiveSupport::Cache::MemoryStore.new
    end

    def locate(key)
      source = @store.read(key)

      if source.blank?
        source = Source.create_or_find_by(key: key)
        expires_in = source.analyzed ? nil : 1.minute
        @store.write(key, source, expires_in: expires_in)
      end

      source
    end
  end
end
