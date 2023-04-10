class AddDownloadBpsToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :download_bps, :float, default: 0.0
  end
end
