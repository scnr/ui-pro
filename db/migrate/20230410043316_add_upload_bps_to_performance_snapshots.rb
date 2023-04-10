class AddUploadBpsToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :upload_bps, :float, default: 0.0
  end
end
