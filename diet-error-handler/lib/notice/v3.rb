require "yaml"

module Notice
  class V3
    attr_reader :json, :timestamp

    def initialize(json, timestamp)
      @json = json
      @timestamp = timestamp
    end

    def errors
      json["errors"].map do |error|
        { type: error["type"], message: error["message"] }
      end
    end

    def context
      {
        environment: json["context"]["environment"],
        hostname: json["context"]["hostname"],
        url: json["context"]["url"],
        component: json["context"]["component"],
        action: json["context"]["action"],
      }
    end

    def dump
      "---\ntimestamp: #{timestamp}\n#{json.to_yaml}\n"
    end
  end
end
