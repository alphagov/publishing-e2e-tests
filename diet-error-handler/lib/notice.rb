require "nokogiri"
require "json"
require_relative "notice/sentry"

module Notice
  def self.from_sentry(notice_json)
    json = JSON.parse(notice_json.force_encoding("UTF-8"))
    Notice::Sentry.new(json, Time.now)
  end
end
