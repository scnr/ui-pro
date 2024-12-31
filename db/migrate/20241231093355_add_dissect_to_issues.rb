class AddDissectToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :dissect, :text
  end
end
