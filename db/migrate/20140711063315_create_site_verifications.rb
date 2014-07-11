class CreateSiteVerifications < ActiveRecord::Migration
    def change
        create_table :site_verifications do |t|
            t.string :filename
            t.string :state, default: :pending
            t.text   :code
            t.text   :message
            t.belongs_to :site

            t.timestamps
        end
    end
end
