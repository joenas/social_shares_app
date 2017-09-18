require 'sinatra'
require 'sinatra/json'
require 'social_shares'
require 'dalli'

NETWORKS = [:facebook, :google, :reddit, :mail_ru, :vkontakte]#, :odnoklassniki, :weibo, :buffer, :hatebu]

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

def client
  @client ||= Dalli::Client.new(ENV['MEMCACHED_URL'], expires_in: ENV['MEMCACHED_EXPIRES_IN'].to_i)
end
