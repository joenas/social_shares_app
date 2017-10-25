class FetchImagesWorker
  include Sidekiq::Worker

  def perform(fetched_at)
    redis = Redis.new(url: ENV['REDIS_URL'])
    fetch = JsonClient.new(ENV['THUMBOR_URL'])
    items = Oj.load(redis.get('news') || '{}')
    items =  items.select{|_id, item| item[:fetched_at] >= fetched_at}
    items.each {|(_, item)| fetch.head('/unsafe/' + item[:image])}
  end
end
