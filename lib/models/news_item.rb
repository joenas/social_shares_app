class NewsItem < ActiveRecord::Base
  belongs_to :source, class_name: "NewsSource", foreign_key: :news_source_id
  validates_uniqueness_of :url
end
