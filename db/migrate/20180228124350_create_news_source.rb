class CreateNewsSource < ActiveRecord::Migration[5.1]
  def change
    create_table :news_sources do |t|
      t.string :name
      t.string :avatar_url
      t.integer :min_count
    end
  end
end
