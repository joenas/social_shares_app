require 'dotenv/load'

env = ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development
EMPTY = ''.freeze

# Load dependencies
require 'bundler'
Bundler.require(:default, env)

require './lib/json_client'
require './lib/fetch_image_worker'
require './lib/fetch_item_worker'
require './lib/influx_worker'
require './lib/news_counts_worker'
require './lib/webhook_worker'
require_relative './lib/models/news_source'
require_relative './lib/models/news_item'
require_relative './lib/decorators/news_item_decorator'

OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL'] + "?pool=" + (ENV['DATABASE_POOL'] || '5')

NETWORKS = [:facebook, :google, :reddit, :mail_ru, :vkontakte]#, :odnoklassniki, :weibo, :buffer, :hatebu]
MAX_RETRIES = 48

