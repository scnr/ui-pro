class AddMissingIssuesAssociationToRevisions < ActiveRecord::Migration[7.0]
  def change
    create_table :missing_issues_revisions, id: false do |t|
      t.belongs_to :issue
      t.belongs_to :revision
  end
end
end
