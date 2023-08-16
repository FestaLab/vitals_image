# frozen_string_literal: true

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
          source = find_or_create_by(key)
          expires_in = source.analyzed ? nil : 1.minute
          @store.write(key, source, expires_in: expires_in)
        end

        source
      end
    end

    private
      def find_or_create_by(key)
        uri = URI.parse(key)

        if VitalsImage.domains.present? && !VitalsImage.domains.include?(uri.host)
          Source.new(key: key, metadata: { identified: false })
        else
          Source.find_or_create_by(key: key) { |source| source.identified = true }
        end
      end

      def with_retry
        yield
      rescue ActiveRecord::RecordNotUnique
        yield
      end
  end
end
