MAX_TO_KEEP = 500
require 'digest/sha1'

class NewsWorker
  include Sidekiq::Worker

  def perform()
    fetch = JsonClient.new(ENV['NEWS_URL'])
    redis = Redis.new(url: ENV['REDIS_URL'])
    items = fetch.get('').body['items']
    fetched_at = Time.now.to_i
    # objects = items.map {|item| NewsItem.new(item)}
    # by_id = objects.each_with_object({}){|item, memo| memo[item.id] = item.to_h}

    hashes = items.map {|item| item.merge(id: Digest::SHA1.hexdigest(item['link']), fetched_at: fetched_at).symbolize_keys}
    by_id = hashes.each_with_object({}){|item, memo| memo[item[:id]] = item}

    current_items = Oj.load(redis.get('news') || '{}')

    items = Hash[by_id.merge(current_items).take(MAX_TO_KEEP)]
    redis.set('news', Oj.dump(items))
    FetchImagesWorker.perform_async(fetched_at)
    NewsWorker.perform_in(ENV['FETCH_NEWS_INTERVAL'].to_i*60)
  end
end
