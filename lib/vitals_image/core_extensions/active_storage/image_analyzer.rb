# frozen_string_literal: true

module VitalsImage
  module CoreExtensions
    module ActiveStorage
      class ImageAnalyzer < ::ActiveStorage::Analyzer
        def self.accept?(blob)
          blob.image?
        end

        def metadata
          read_image do |image|
            if rotated_image?(image)
              { width: image.height, height: image.width }
            else
              { width: image.width, height: image.height }
            end
          end
        end

        private
          def read_image
            download_blob_to_tempfile do |file|
              require "ruby-vips"
              image = Vips::Image.new_from_file(file.path, access: :sequential)

              if valid_image?(image)
                yield image
              else
                logger.info "Skipping image analysis because Vips doesn't support the file"
                {}
              end
            end
          rescue LoadError
            logger.info "Skipping image analysis because the ruby-vips gem isn't installed"
            {}
          rescue Vips::Error => error
            logger.error "Skipping image analysis due to an Vips error: #{error.message}"
            {}
          end

          ROTATIONS = /Right-top|Left-bottom|Top-right|Bottom-left/

          def rotated_image?(image)
            ROTATIONS === image.get("exif-ifd0-Orientation")
          rescue ::Vips::Error
            false
          end

          def valid_image?(image)
            image.avg
            true
          rescue ::Vips::Error
            false
          end
      end
    end
  end
end
