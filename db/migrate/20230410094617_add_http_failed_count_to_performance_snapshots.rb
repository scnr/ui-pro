class AddHttpFailedCountToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :http_failed_count, :integer, default: 0
  end
end
