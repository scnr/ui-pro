class AddSecondsPerBrowserJobToPerformanceSnapshots < ActiveRecord::Migration[7.0]
  def change
    add_column :performance_snapshots, :seconds_per_browser_job, :float, default: 0.0
  end
end
