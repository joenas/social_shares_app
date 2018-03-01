class AddIndexToNewsItems < ActiveRecord::Migration[5.1]
  def change
    add_index(:news_items, :url, unique: true)
  end
end
