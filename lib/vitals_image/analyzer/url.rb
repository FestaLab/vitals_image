# frozen_string_literal: true

require "open-uri"

module VitalsImage
  class Analyzer::Url < Analyzer
    def self.accept?(source)
      source.is_a?(Source)
    end

    def analyze
      file = download
      image = open(file)
      mime  = Marcel::MimeType.for(Pathname.new file.path)

      source.update width: image.width, height: image.height, analyzed: true, content_type: mime
    end

    private
      def open(file)
        if VitalsImage.image_library == :mini_magick
          MiniMagick::Image.new(file.path).tap do |image|
            raise "Invalid image" unless image.valid?
          end
        else
          Vips::Image.new_from_file(file.path, access: :sequential).tap do |image|
            image.avg
          end
        end
      end

      def download
        uri = URI.parse(source.key)
        io = uri.open
        downloaded = Tempfile.new([File.basename(uri.path), File.extname(uri.path)])

        if io.is_a?(Tempfile)
          FileUtils.mv io.path, downloaded.path
        else
          # StringIO
          File.write(downloaded.path, io.string)
        end

        downloaded
      rescue
        logger.error "Failed to download #{source.key}"
        raise
      end
  end
end
