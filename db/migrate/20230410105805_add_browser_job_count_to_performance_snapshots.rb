class AddBrowserJobCountToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :browser_job_count, :integer, default: 0
  end
end
