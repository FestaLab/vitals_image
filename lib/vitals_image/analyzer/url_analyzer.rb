# frozen_string_literal: true

require "open-uri"

module VitalsImage
  class Analyzer::UrlAnalyzer < Analyzer
    def self.accept?(source)
      source.is_a?(Source)
    end

    def analyze
      file  = download
      image = open(file)
      mime  = Marcel::MimeType.for(Pathname.new file.path)

      source.update! width: image.width, height: image.height, analyzed: true, content_type: mime
    rescue OpenURI::HTTPError
      source.update! analyzed: true, identified: false
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
        uri        = URI.parse(source.key)
        io         = uri.open(ssl_verify_mode: ssl_verify_mode)
        uri_path   = truncate_uri_path(uri.path)
        downloaded = Tempfile.new([File.basename(uri_path), File.extname(uri_path)], binmode: true)

        if io.is_a?(Tempfile)
          FileUtils.mv io.path, downloaded.path
        else
          # StringIO
          File.write(downloaded.path, io.string, mode: "wb")
        end

        downloaded
      end

      def truncate_uri_path(uri_path)
        parts     = uri_path.split(".")
        filename  = parts.first[0..200]
        extension = parts.last

        [filename, extension].join(".")
      end

      def ssl_verify_mode
        VitalsImage.skip_ssl_verification ? OpenSSL::SSL::VERIFY_NONE : nil
      end
  end
end
