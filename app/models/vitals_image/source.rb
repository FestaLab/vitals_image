# frozen_string_literal: true

module VitalsImage
  class Source < ApplicationRecord
    store :metadata, accessors: [ :analyzed, :width, :height ], coder: ActiveRecord::Coders::JSON, default: "{ analyzed: false }"

    after_create -> { AnalyzeJob.perform_later(self) }
  end
end
