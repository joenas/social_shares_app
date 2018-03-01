class AddFieldsToNewsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :news_items, :image, :string
    add_column :news_items, :fetched_at, :datetime
  end
end
