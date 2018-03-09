class FetchItemWorker
  include Sidekiq::Worker

  class NewsConnectError < StandardError; end

  def perform(id)
    item = NewsItem.find(id)
    client = WebClient.new(item.url)
    resp = client.get('')

    raise(NewsConnectError, resp.body) unless resp.success?

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
    FetchImageWorker.perform_async(image) if image.present?
  end
end
