class AddProcessingToScans < ActiveRecord::Migration[7.0]
  def change
    add_column :scans, :processing, :string
  end
end
