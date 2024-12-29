class AddRemediationCodeRemediationGuidanceDescriptionToIssues < ActiveRecord::Migration[7.0]
  def change
    add_column :issues, :remediation_code, :text
    add_column :issues, :remediation_guidance, :text
    add_column :issues, :description, :text
  end
end
