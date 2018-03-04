require './api'
require 'sidekiq/web'

use Raven::Rack
use OTR::ActiveRecord::ConnectionManagement
use Rack::Session::Cookie, secret: ENV['SECRET_KEY']
Sidekiq::Web.set :session_secret, ENV['SECRET_KEY']

run Rack::URLMap.new('/' => SocialSharesApp, '/sidekiq' => Sidekiq::Web)
