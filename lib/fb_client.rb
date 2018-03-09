class FbClient

  FB_URL = ENV['SOCIAL_SHARES_FACEBOOK_URL'] || 'http://graph.facebook.com/v2.7/'

  class FbConnectError < StandardError; end

  def self.share_count(url)
    client = WebClient.new(FB_URL)
    response = client.get(FB_URL, {id: url, fields: 'share'})
    if response.success?
      json = Oj.load(response.body)
      json.fetch('share').fetch('share_count')
    else
      raise FbConnectError, response.body
    end
  end

end
