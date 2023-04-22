class AddAuditModeToSiteProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :site_profiles, :audit_mode, :string, default: SCNR::Engine::Options.audit.mode.to_s
  end
end
