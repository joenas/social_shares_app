require 'grape'
require 'social_shares'
require 'dalli'
require 'redis'
require 'sidekiq'
require 'oj'
require 'multi_json'

require './lib/json_client'
require './lib/min_count_worker'
require './lib/influx_worker'
require './lib/news_worker'
require './lib/news_item'


NETWORKS = [:facebook, :google, :reddit, :mail_ru, :vkontakte]#, :odnoklassniki, :weibo, :buffer, :hatebu]
MAX_RETRIES = 48

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
end
