class CreateDevices < ActiveRecord::Migration[5.1]
    def change
        create_table :devices do |t|
            t.boolean :default
            t.string  :name
            t.text    :device_user_agent
            t.integer :device_width
            t.integer :device_height
            t.boolean :device_touch
            t.float   :device_pixel_ratio

            t.timestamps
        end
    end
end
