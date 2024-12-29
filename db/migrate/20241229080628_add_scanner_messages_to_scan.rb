class AddScannerMessagesToScan < ActiveRecord::Migration[7.0]
  def change
    add_column :scans, :scanner_messages, :binary
  end
end
