# frozen_string_literal: true

Rails.application.routes.draw do
  mount VitalsImage::Engine => "/vitals_image"
end
