class AddBelongsToProfileToScans < ActiveRecord::Migration[5.1]
    def change
        add_reference :scans, :profile, index: true
    end
end
