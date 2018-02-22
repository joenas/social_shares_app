require 'grape'
require 'social_shares'
require 'dalli'
require 'redis'
require 'sidekiq'
require 'oj'
require 'multi_json'

require './lib/json_client'
require './lib/min_count_worker'
require './lib/influx_worker'
require './lib/news_worker'
require './lib/news_item'
require './lib/fetch_images_worker'


NETWORKS = [:facebook, :google, :reddit, :mail_ru, :vkontakte]#, :odnoklassniki, :weibo, :buffer, :hatebu]
MAX_RETRIES = 48

