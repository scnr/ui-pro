class CreateVersions < ActiveRecord::Migration

    # The largest text column available in all supported RDBMS is
    # 1024^3 - 1 bytes, roughly one gibibyte.  We specify a size
    # so that MySQL will use `longtext` instead of `text`.  Otherwise,
    # when serializing very large objects, `text` might not be big enough.
    TEXT_BYTES = 1_073_741_823

    def change
        create_table :versions do |t|
            t.string :item_type, :null => false
            t.integer :item_id, :null => false
            t.string :event, :null => false

            # We need explicit columns to allow parents (like site) to easily grab
            # version for their children, even when deleted.
            t.integer :site_id
            t.integer :scan_id
            t.integer :revision_id

            # Useful for destroyed records, allows us to be able to show something
            # useful instead of an ID.
            t.text :object_to_s

            t.string :whodunnit
            t.jsonb :object
            t.datetime :created_at
        end

        add_index :versions, [:item_type, :item_id]
        add_index :versions, :whodunnit
        add_index :versions, :site_id
        add_index :versions, :scan_id
        add_index :versions, :revision_id

    end
end
