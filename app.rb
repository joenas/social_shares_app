require 'sinatra'
require 'sinatra/json'
require 'social_shares'

NETWORKS = [:facebook, :google, :reddit]#, :mail_ru, :vkontakte, :odnoklassniki, :weibo, :buffer, :hatebu]

get '/all' do
  json SocialShares.selected(params[:url], NETWORKS)
end

get '/total' do
  json count: SocialShares.total(params[:url], NETWORKS)
end
