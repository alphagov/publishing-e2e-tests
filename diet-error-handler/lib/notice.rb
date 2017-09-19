require "nokogiri"
require "json"
require_relative "notice/v2"
require_relative "notice/v3"
require_relative "notice/sentry"

module Notice
  def self.from_v2(notice_xml)
    xml = Nokogiri::XML(notice_xml.force_encoding("UTF-8"))
    Notice::V2.new(xml, Time.now)
  end

  def self.from_v3(notice_json)
    json = JSON.parse(notice_json.force_encoding("UTF-8"))
    Notice::V3.new(json, Time.now)
  end

  def self.from_sentry(notice_json)
    json = JSON.parse(notice_json.force_encoding("UTF-8"))
    Notice::Sentry.new(json, Time.now)
  end
end
