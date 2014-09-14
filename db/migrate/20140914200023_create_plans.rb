class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.text :description
      t.float :price
      t.integer :profile_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
