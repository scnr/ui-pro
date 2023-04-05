class AddProcessingToSites < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :processing, :string
  end
end
