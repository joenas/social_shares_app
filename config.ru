require './api'
require 'sidekiq/web'
run Rack::URLMap.new('/' => SocialSharesApp, '/sidekiq' => Sidekiq::Web)
