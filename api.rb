require './app'

class SocialSharesApp < Grape::API

  version 'v1', using: :header, vendor: 'social_shares_app'
  format :json

  helpers do
    def client
      @client ||= Dalli::Client.new(ENV['MEMCACHED_URL'], expires_in: ENV['MEMCACHED_EXPIRES_IN'].to_i)
    end

    def redis
      @redis ||= Redis.new(url: ENV['REDIS_URL'])
    end
  end

  desc 'Get news feed'
  params do
    optional 'last-modified', type: Integer
  end
  get :news do
    items = Oj.load(redis.get('news') || '{}')
    NewsWorker.perform_async if items.empty?
    items = params['last-modified'].present? ? items.select{|_id, item| item[:fetched_at] >= params['last-modified']} : items
    {items: items, ids: items.keys}
  end

  desc 'Get social shares count per network for :url'
  get :all do
    client.fetch("all/#{params[:url]}") {SocialShares.selected(params[:url], NETWORKS)}
  end

  desc 'Get total social shares count for :url'
  get :total do
    count = client.fetch("total/#{params[:url]}") {SocialShares.total(params[:url], NETWORKS)}
    {count: count}
  end

  desc 'Periodically check social shares count and POST to callback_url when min_count is achieved'
  params do
    requires :url, type: String
    requires :min_count, type: Integer
    requires :callback_url, type: String
  end
  post :mincount do
    MinCountWorker.perform_async(params)
    {status: :ok}
  end

  desc 'Create NewsSource'
  params do
    requires :name, type: String
    requires :min_count, type: Integer
    requires :avatar_url, type: String
  end
  post :news_sources do
    NewsSource.create! params
  end

  desc 'Create NewsItem'
  params do
    requires :source, type: String
    requires :url, type: String
    requires :title, type: String
    requires :description, type: String
    requires :published_at, type: DateTime
  end
  post :news_items do
    source = NewsSource.find_by_name!(params.delete(:source))
    item = NewsItem.create! declared(params).merge(news_source_id: source.id, description: params[:description].tr('<![CDATA[',EMPTY).tr(']]>', EMPTY))
    NewsCountsWorker.perform_async(item.id)
    item
  end

  desc 'Get news feed'
  params do
    optional 'last-modified', type: Integer
  end
  get :news_items do
    items = NewsItem.where.not(fetched_at: nil)
    items = params['last-modified'].present? ? items.where("fetched_at >= ?", DateTime.strptime(params['last-modified'].to_s,'%s')) : items.all
    decorated = NewsItemDecorator.decorate_collection items.preload(:source).order(published_at: :desc).limit(500)
    by_id = decorated.each_with_object({}){|item, memo| memo[item[:id]] = item.to_h}
    {items: by_id, ids: by_id.keys}
  end
end
