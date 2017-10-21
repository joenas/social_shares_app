require 'digest/sha1'
class NewsItem
  include Virtus.model

  attribute :link
  attribute :image
  attribute :source
  attribute :title
  attribute :description
  attribute :keywords
  attribute :date
  attribute :content_truncated
  attribute :content_html
  attribute :pubDate
  attribute :id
  attribute :fetched_at

  def id
    Digest::SHA1.hexdigest(link)
  end

  def fetched_at
    Time.now.to_i
  end

end
