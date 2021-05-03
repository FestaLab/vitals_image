# frozen_string_literal: true

class CreateVitalsImageSources < ActiveRecord::Migration[6.1]
  def change
    create_table :vitals_image_sources do |t|
      t.string :key, null: false
      t.string :content_type
      t.text   :metadata

      t.timestamps

      t.index [ :key ], unique: true
    end
  end
end
