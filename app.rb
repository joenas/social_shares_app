require 'sinatra'
require 'sinatra/json'
require 'social_shares'
require 'dalli'
require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'faraday'
require 'faraday_middleware'

NETWORKS = [:facebook, :google, :reddit, :mail_ru, :vkontakte]#, :odnoklassniki, :weibo, :buffer, :hatebu]
MAX_RETRIES = 25

class JsonClient < SimpleDelegator

  def initialize(url, &block)
    @url = url
    super client(&block)
  end

  def client
    Faraday.new @url do |connection|
      yield connection if block_given?
      connection.request :json
      connection.response :json, content_type: 'application/json'
      connection.adapter Faraday.default_adapter
    end
  end
end

class MinCountWorker
  include Sidekiq::Worker

  def perform(url, min_count, callback_url, retries = 0)
    count = SocialShares.total(url, NETWORKS)
    retries = retries + 1
    if count >= min_count.to_i
      client = JsonClient.new(callback_url)
      client.post('', {
        "url": url,
        "count": count
      })
    elsif retries < MAX_RETRIES
      MinCountWorker.perform_in(60*60, url, min_count, callback_url, retries)
    else
      # DIE
    end
  end
end

get '/all' do
  data = client.fetch("all/#{params[:url]}") {SocialShares.selected(params[:url], NETWORKS)}
  json data
end

get '/total' do
  count = client.fetch("total/#{params[:url]}") {SocialShares.total(params[:url], NETWORKS)}
  json count: count
end

get '/filter' do
  count = client.fetch("total/#{params[:url]}") {SocialShares.total(params[:url], NETWORKS)}

  reply = {count: count}
  if !params[:min_count]
    status 422
    reply[:error] = "Param min_count is needed"
  elsif count < params[:min_count].to_i
    # Just using not-200 here
    status 204
  end
  json reply
end

get '/mincount' do
  url, min_count, callback_url = params.values_at('url', 'min_count', 'callback_url')
  if url && min_count && callback_url
    status 200
    MinCountWorker.perform_async(url, min_count, callback_url)
    json status: :ok
  else
    status 422
    json error: "Params missing"
  end
end

def client
  @client ||= Dalli::Client.new(ENV['MEMCACHED_URL'], expires_in: ENV['MEMCACHED_EXPIRES_IN'].to_i)
end
