class AddTotalAverageAppTimeToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :total_average_app_time, :float, default: 0.0
  end
end
