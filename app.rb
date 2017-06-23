require 'sinatra'
require 'sinatra/json'
require 'social_shares'
require 'dalli'

NETWORKS = [:facebook, :google, :reddit]#, :mail_ru, :vkontakte, :odnoklassniki, :weibo, :buffer, :hatebu]

get '/all' do
  data = client.fetch(params[:url]) {SocialShares.selected(params[:url], NETWORKS)}
  json data
end

get '/total' do
  count = client.fetch(params[:url]) {SocialShares.total(params[:url], NETWORKS)}
  json count: count
end

def client
  @client ||= Dalli::Client.new(ENV['MEMCACHED_UR'], expires_in: ENV['MEMCACHED_EXPIRES_IN'].to_i)
end
