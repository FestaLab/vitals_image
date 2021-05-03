# frozen_string_literal: true

module VitalsImage
  class Cache
    include Singleton

    def initialize
      @store = ActiveSupport::Cache::MemoryStore.new
    end

    def locate(key)
      @store.fetch(key) { Source.find_or_create_by!(key: key) }
    end
  end
end
