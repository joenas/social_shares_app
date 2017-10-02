require 'influxdb'

class InfluxWorker
  include Sidekiq::Worker

  def perform(params)
    url = ENV["INFLUXDB_URL"]
    influxdb = InfluxDB::Client.new url: url, auth_method: 'basic_auth'
    data = [
      {
        series: 'min_count',
        tags:   { source: params['source']},
        values: { value: params['min_count'] },
      },
      {
        series: 'actual_count',
        tags:   { source: params['source']},
        values: { value: params['count'] },
      }
    ]
    influxdb.write_points(data)
  end
end
