require 'patron'
class FetchImagesWorker
  include Sidekiq::Worker

  def perform(fetched_at)
    redis = Redis.new(url: ENV['REDIS_URL'])
    fetch = Patron::Session.new({ timeout: 10, base_url: ENV['THUMBOR_URL']} )
    items = Oj.load(redis.get('news') || '{}')
    items =  items.select{|_id, item| item[:fetched_at] >= fetched_at}
    items.each {|(_, item)| fetch.head(item[:image])}
  end
end
