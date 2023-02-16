# frozen_string_literal: true

module VitalsImage
  class TinyGif
    include Singleton

    def processed
      self
    end

    def url
      Base::TINY_GIF
    end
  end

end
