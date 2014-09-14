class AddPlanIdToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :plan_id, :integer
  end
end
