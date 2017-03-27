require "sinatra"
require "sinatra/json"
require "json"
require "yaml"

ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors.log")
VERBOSE_ERROR_LOG = ENV.fetch("ERROR_LOG", "/app/tmp/errors-verbose.log")

get "/" do
  json greeting: "Hello, this is a quick lo-fi alternative to errbit for logging errors to a file."
end

post "/api/v3/projects/:project_id/notices" do
  error = JSON.parse(request.body.read.to_s.force_encoding("UTF-8"))

  log_error(error)
  write_error_to_file(error)
  write_verbose_error_to_file(error)

  # Respond with what airbrake is expecting
  status 201
  json id: 1, url: ""
end

def log_error(error)
  error["errors"].each { |e| logger.info("#{e['type']} #{e['message']}") }
end

def write_error_to_file(error)
  abridged_error = {
    timestamp: Time.now,
    errors: error["errors"].map do |e|
      message = (e["message"] || "")[0...150]
      { type: e["type"], message: message }
    end,
    context: error["context"],
    }
  File.open(ERROR_LOG, "a") { |f| f << abridged_error.to_yaml }
end

def write_verbose_error_to_file(error)
  error = { "timestamp" => Time.now }.merge(error) unless error["timestamp"]
  File.open(VERBOSE_ERROR_LOG, "a") { |f| f << error.to_yaml }
end
