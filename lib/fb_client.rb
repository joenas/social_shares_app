class FbClient

  FB_URL = ENV['SOCIAL_SHARES_FACEBOOK_URL'] || 'http://graph.facebook.com/v2.7/'

  class FbConnectError < StandardError; end

  def self.share_count(url)
    client = Faraday.new(FB_URL) { |b|
      b.use FaradayMiddleware::FollowRedirects
      b.adapter :patron
    }
    response = client.get(FB_URL, {id: url, fields: 'share'})
    if response.success?
      json = Oj.load(response.body)
      json.fetch('share').fetch('share_count')
    else
      raise FbConnectError, response.body
    end
  end

end
