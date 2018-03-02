require 'patron'
class FetchImageWorker
  include Sidekiq::Worker

  def perform(image)
    Patron::Session.new({timeout: 10, base_url: ENV['THUMBOR_URL']}).head(image)
  end
end
