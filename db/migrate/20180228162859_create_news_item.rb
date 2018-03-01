class CreateNewsItem < ActiveRecord::Migration[5.1]
  def change
    create_table :news_items, id: :uuid  do |t|
      t.references :news_source
      t.string :url
      t.string :title
      t.string :description
      t.text :content
      t.integer :share_count
      t.datetime :published_at
      t.timestamps
    end
  end
end
