class AddOpenAiKeytoSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :openai_key, :string
  end
end
