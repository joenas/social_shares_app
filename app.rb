require 'dotenv/load'

env = ENV['RACK_ENV'] ? ENV['RACK_ENV'].to_sym : :development
EMPTY = ''.freeze

# Load dependencies
require 'bundler'
Bundler.require(:default, env)

require './lib/json_client'
require './lib/fb_client'
require './lib/web_client'
require './lib/workers/fetch_image_worker'
require './lib/workers/fetch_item_worker'
require './lib/workers/influx_worker'
require './lib/workers/news_counts_worker'
require './lib/workers/webhook_worker'
require './lib/models/news_source'
require './lib/models/news_item'
require './lib/decorators/news_item_decorator'

OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL'] + "?pool=" + (ENV['DATABASE_POOL'] || '5')

Raven.configure do |config|
  config.dsn = ENV['RAVEN_DSN']
end

MAX_RETRIES = 48

