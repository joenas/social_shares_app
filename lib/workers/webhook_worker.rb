class WebhookWorker
  include Sidekiq::Worker

  def perform(id)
    news = NewsItem.find(id)
    client = JsonClient.new(ENV["NEWS_WEBHOOK_URL"])
    news_url = [ENV['NEWS_ITEM_URL'], news.id].join('')
    message = "<a href='#{news_url}'>#{news.title}</a>"
    client.post("", {
      text: message,
      format: "html",
      displayName: news.source.name,
      #avatarUrl: news.source.avatar_url,
      msgtype: "notice"
    })
  end
end
