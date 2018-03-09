class WebClient < SimpleDelegator
  def initialize(url, &block)
    @url = url
    super client(&block)
  end

  def client
    Faraday.new @url do |connection|
      yield connection if block_given?
      connection.use FaradayMiddleware::FollowRedirects
      connection.adapter :patron
    end
  end
end
