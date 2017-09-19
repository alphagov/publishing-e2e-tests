require "yaml"

module Notice
  class Sentry
    attr_reader :json, :timestamp

    def initialize(json, timestamp)
      @json = json
      @timestamp = timestamp
    end

    def errors
      json["exception"]["values"].map do |exception|
        { type: exception["type"], message: exception["value"] }
      end
    end

    def context
      {
        environment: json["environment"],
        hostname: json.dig("request", "headers", "Host"),
        url: json.dig("request", "url"),
      }
    end

    def dump
      "---\ntimestamp: #{timestamp.to_s}\n#{json.to_yaml}\n"
    end
  end
end
