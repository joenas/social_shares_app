class MinCountWorker
  include Sidekiq::Worker

  def perform(params, retries = 0)
    count = SocialShares.total(params['url'], NETWORKS)
    params.merge!(count: count)
    if count >= params['min_count'].to_i
      callback_url = params.delete('callback_url')
      client = JsonClient.new(callback_url)
      client.post('', params)
      InfluxWorker.perform_async(params)
    elsif retries < MAX_RETRIES
      retries = retries + 1
      MinCountWorker.perform_in(30*60, params, retries)
    else
      InfluxWorker.perform_async(params)
    end
  end
end
