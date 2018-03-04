require './app'

class SocialSharesApp < Grape::API
  rescue_from :all

  version 'v1', using: :header, vendor: 'social_shares_app'
  format :json

  helpers do
    def cache
      @cache ||= Dalli::Client.new(ENV['MEMCACHED_URL'], expires_in: ENV['MEMCACHED_EXPIRES_IN'].to_i)
    end
  end

  desc 'Get social shares count per network for :url'
  get :all do
    cache.fetch("all/#{params[:url]}") {SocialShares.selected(params[:url], NETWORKS)}
  end

  desc 'Get total social shares count for :url'
  get :total do
    count = cache.fetch("total/#{params[:url]}") {SocialShares.total(params[:url], NETWORKS)}
    {count: count}
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
    item = NewsItem.create! declared(params).merge(news_source_id: source.id, description: params[:description].gsub('<![CDATA[',EMPTY).gsub(']]>', EMPTY))
    NewsCountsWorker.perform_async(item.id)
    item
  end

  desc 'Get news feed'
  params do
    optional 'last-modified', type: Integer
  end
  get :news_items do
    last_modified = params.fetch('last-modified', 1.month.ago.to_i).to_s
    items = NewsItem.where("fetched_at >= ?", DateTime.strptime(last_modified,'%s')).preload(:source).order(published_at: :desc)
    decorated = NewsItemDecorator.decorate_collection items
    by_id = decorated.each_with_object({}){|item, memo| memo[item[:id]] = item.to_h}
    {items: by_id, ids: by_id.keys}
  end

  desc 'Redirect to NewsItem'
  params do
    requires :id, type: String, desc: 'Status id.'
  end
  get 'news_item/:id' do
    item = NewsItem.find_by_id(params[:id])
    error!({ error: 'Not found'}, 404) unless item
    item.update views: item.views+1
    redirect item.url
  end
end
