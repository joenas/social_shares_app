require 'influxdb'

class InfluxWorker
  include Sidekiq::Worker

  def perform(id)
    item = NewsItem.find(id)
    share_count, min_count, source = item.share_count, item.source.min_count, item.source.name
    influxdb = InfluxDB::Client.new url: ENV["INFLUXDB_URL"], auth_method: 'basic_auth'
    data = [
      {
        series: 'min_count',
        tags:   { source: source},
        values: { value: min_count },
      },
      {
        series: 'actual_count',
        tags:   { source: source},
        values: { value: share_count },
      }
    ]
    influxdb.write_points(data)
  end
end
