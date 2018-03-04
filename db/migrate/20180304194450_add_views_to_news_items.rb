class AddViewsToNewsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :news_items, :views, :integer, default: 0, nil: false
    add_index :news_items, :views
  end
end
