# frozen_string_literal: true

module VitalsImage
  module CoreExtensions
    module ActiveStorage
      class IsolatedImageAnalyzer < ImageAnalyzer
        def metadata
          read_image do |image|
            if rotated_image?(image)
              { width: image.height, height: image.width, isolated: isolated?(image) }
            else
              { width: image.width, height: image.height, isolated: isolated?(image) }
            end
          end
        end

        private
          def isolated?(image)
            corners = extract_corner_areas(image)
            colors  = corners.map { |corner| primary_color_for(corner) }
            colors.all? { |color| color.all? { |value| value > 250 } }
          rescue
            false
          end

          def extract_corner_areas(image)
            paths = []

            basename = SecureRandom.urlsafe_base64
            width    = image.width
            height   = image.height
            size     = 8

            filename = Rails.root.join("tmp", "#{basename}.jpg")
            `vips copy #{image.filename} #{filename}`

            paths << Rails.root.join("tmp", "#{basename}_top_left.jpg")
            `vips im_extract_area #{filename} #{paths.last} 0 0 #{size} #{size}`

            paths << Rails.root.join("tmp", "#{basename}_top_right.jpg")
            `vips im_extract_area #{filename} #{paths.last} #{width - size} 0 #{size} #{size}`

            paths << Rails.root.join("tmp", "#{basename}_bottom_right.jpg")
            `vips im_extract_area #{filename} #{paths.last} #{width - size} #{height - size} #{size} #{size}`

            paths << Rails.root.join("tmp", "#{basename}_bottom_left.jpg")
            `vips im_extract_area #{filename} #{paths.last} 0 #{height - size} #{size} #{size}`

            paths
          end

          def primary_color_for(filepath)
            histogram = generate_color_histogram(filepath)
            sorted    = sort_by_frequency(histogram)
            extract_dominant_rgb(sorted)
          end

          def generate_color_histogram(path)
            `convert #{path} +dither -colors 5 -define histogram:unique-colors=true -format "%c" histogram:info:`
          end

          def sort_by_frequency(histogram)
            histogram.each_line.map { |line| parts = line.split(":"); [parts[0].to_i, parts[1]] }.sort_by { |line| line[0] }.reverse
          end

          def extract_dominant_rgb(array)
            array.map { |line| line[1].match(/\(([\d.,]+)/).captures.first.split(",").take(3).map(&:to_i) }.first
          end
      end
    end
  end
end
