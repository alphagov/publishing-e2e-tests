require "sinatra"
require "sinatra/json"
require "nokogiri"
require "yaml"
require_relative "lib/notice"

ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors.log")
VERBOSE_ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors-verbose.log")

get "/" do
  json greeting: "Hello, this is a quick lo-fi alternative to errbit for logging errors to a file."
end

post "/api/v3/projects/:project_id/notices" do
  notice = Notice.from_v3(request.body.read.to_s)
  handle_notice(notice)

  # Respond with what airbrake is expecting
  status 201
  json id: 1, url: ""
end

post "/notifier_api/v2/notices" do
  begin
    notice = Notice.from_v2(request.body.read.to_s)
    handle_notice(notice)
    status 200
    body "Success"
  rescue Nokogiri::XML::SyntaxError
    status 422
    body "The provided XML was not well formed"
  end
end

def handle_notice(notice)
  log_errors(notice.errors)
  write_to_log(notice)
  write_to_verbose_log(notice)
end

def log_errors(errors)
  errors.each do |e|
    logger.info("#{e[:type]} #{abridged_message(e[:message])}")
  end
end

def abridged_message(message)
  (message || "")[0...150]
end

def write_to_log(notice)
  abridged_notice = {
    timestamp: notice.timestamp,
    errors: notice.errors.map { |e| e.merge(message: abridged_message(e[:message])) },
    context: notice.context,
    }
  File.open(ERROR_LOG, "a") { |f| f << abridged_notice.to_yaml }
end

def write_to_verbose_log(notice)
  File.open(VERBOSE_ERROR_LOG, "a") { |f| f << notice.dump }
end
