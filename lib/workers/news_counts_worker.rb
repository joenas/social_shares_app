class NewsCountsWorker
  include Sidekiq::Worker

  def perform(id, retries = 0)
    item = NewsItem.find(id)
    count = FbClient.share_count(item.url)
    item.update share_count: count
    if count >= item.source.min_count
      WebhookWorker.perform_async(id)
      InfluxWorker.perform_async(id)
      FetchItemWorker.perform_async(id)
    elsif retries < MAX_RETRIES
      retries = retries + 1
      self.class.perform_in(30*60, id, retries)
    else
      InfluxWorker.perform_async(id)
    end
  end
end
