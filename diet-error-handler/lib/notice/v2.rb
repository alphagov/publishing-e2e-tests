module Notice
  class V2
    attr_reader :xml, :timestamp

    def initialize(xml, timestamp)
      @xml = xml
      @timestamp = timestamp
    end

    def errors
      [{
        type: xml.at_xpath("//notice//error//class")&.text,
        message: xml.at_xpath("//notice//error//message")&.text,
      }]
    end

    def context
      {
        environment: xml.at_xpath("//notice//server-environment//environment-name")&.text,
        hostname: xml.at_xpath("//notice//server-environment//hostname")&.text,
        url: xml.at_xpath("//notice//request//url")&.text,
        component: xml.at_xpath("//notice//request//component")&.text,
        action: xml.at_xpath("//notice//request//action")&.text,
      }
    end

    def dump
      "---\ntimestamp: #{timestamp.to_s}\n#{xml.to_s}\n"
    end
  end
end
