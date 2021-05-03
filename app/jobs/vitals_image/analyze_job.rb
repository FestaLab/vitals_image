# frozen_string_literal: true

module VitalsImage
  class AnalyzeJob < ApplicationJob
    queue_as { ActiveStorage.queues[:analysis] }

    def perform(source)
      VitalsImage::Base.analyzer(source).analyze
    end
  end
end
