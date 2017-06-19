require 'sinatra'
require 'sinatra/json'
require 'social_shares'

get '/all' do
  json SocialShares.all(params[:url])
end

get '/total' do
  json count: SocialShares.total(params[:url])
end
