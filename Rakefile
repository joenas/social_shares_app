require 'dotenv'
Dotenv.load
require "bundler/setup"
load "tasks/otr-activerecord.rake"
OTR::ActiveRecord.configure_from_url! ENV['DATABASE_URL']
