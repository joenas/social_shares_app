class MinCountWorker
  include Sidekiq::Worker

  def perform(params, retries = 0)
    count = SocialShares.total(params['url'], NETWORKS)
    if count >= params['min_count'].to_i
      callback_url = params.delete('callback_url')
      client = JsonClient.new(callback_url)
      client.post('', params.merge(count: count))
    elsif retries < MAX_RETRIES
      retries = retries + 1
      params.merge!(count: count)
      MinCountWorker.perform_in(30*60, params, retries)
    end
  end
end
