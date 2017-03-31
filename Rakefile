require "httparty"
require "plek"
require_relative "lib/retry_while_false"

task :hello do
  puts "hi"
end

task :wait_for_router do
  outcome = RetryWhileFalse.call(reload_seconds: 60, interval_seconds: 1) do
    live = HTTParty.head(Plek.find("www")).code
    draft = HTTParty.head(Plek.find("draft-origin")).code
    live < 500 && draft < 500
  end

  abort "Router has no routes after 60 seconds" unless outcome
end
