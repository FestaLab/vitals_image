class AddFingerprintToVitalsImageSources < ActiveRecord::Migration[6.1]
  def change
    add_column :vitals_image_sources, :fingerprint, :string
    add_index :vitals_image_sources, :fingerprint, unique: true
  end
end
