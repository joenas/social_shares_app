class FetchItemWorker
  include Sidekiq::Worker

  def perform(id)
    item = NewsItem.find(id)
    resp = Faraday.get(item.url)
    doc = Nokogiri::HTML(resp.body)
    options = {
      tags: %w[article p span div],
      remove_empty_nodes: true,
      attributes: %w[b strong em h1 h2 h3],
      blacklist: %w[figcaption figure]
    }
    content = Readability::Document.new(doc.at('body'), options).content.gsub('&#13;', EMPTY).squish
    image = doc.at_xpath("//meta[@name='twitter:image' or @name='twitter:image:src' or @property='twitter:image']").try(:attr, :content)
    item.update content: content, image: image, fetched_at: Time.now
  end
end
