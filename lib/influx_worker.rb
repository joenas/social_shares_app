require 'influxdb'

class InfluxWorker
  include Sidekiq::Worker

  def perform(id_or_params)
    if id_or_params.is_a?(String)
      item = NewsItem.find(id_or_params)
      count, min_count, source = item.share_count, item.source.min_count, item.source.name
    else
      count, min_count, source = id_or_params.values_at('count', 'min_count', 'source')
    end
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
        values: { value: count },
      }
    ]
    influxdb.write_points(data)
  end
end
