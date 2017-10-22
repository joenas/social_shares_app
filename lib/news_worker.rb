MAX_TO_KEEP = 500

class NewsWorker
  include Sidekiq::Worker

  def perform()
    fetch = JsonClient.new(ENV['NEWS_URL'])
    redis = Redis.new(url: ENV['REDIS_URL'])
    items = fetch.get('').body['items'].map {|item| NewsItem.new(item)}
    by_id = items.each_with_object({}){|item, memo| memo[item.id] = item.to_h}
    current_items = Oj.load(redis.get('news') || '{}')
    items = Hash[by_id.merge(current_items).take(MAX_TO_KEEP)]
    redis.set('news', Oj.dump(items))
    NewsWorker.perform_in(1*60)
  end
end
