class AddBelongsToProfileToScans < ActiveRecord::Migration
    def change
        add_reference :scans, :profile, index: true
    end
end
