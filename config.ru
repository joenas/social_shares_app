require './api'
require 'sidekiq/web'
use OTR::ActiveRecord::ConnectionManagement
run Rack::URLMap.new('/' => SocialSharesApp, '/sidekiq' => Sidekiq::Web)
