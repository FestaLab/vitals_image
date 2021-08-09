# frozen_string_literal: true

module VitalsImage
  class Source < ActiveRecord::Base
    store :metadata, accessors: [ :identified, :analyzed, :width, :height ], coder: ActiveRecord::Coders::JSON

    after_create_commit -> { AnalyzeJob.perform_later(self) }
  end
end
