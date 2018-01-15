require "bunny"
require "httparty"
require "plek"
require_relative "lib/retry_while_false"

task :wait_for_router do
  outcome = RetryWhileFalse.call(reload_seconds: 60, interval_seconds: 1) do
    live = HTTParty.head(Plek.find("www")).code
    draft = HTTParty.head(Plek.find("draft-origin")).code
    live < 500 && draft < 500
  end

  abort "Router has no routes after 60 seconds" unless outcome
end

task :setup_rabbitmq_rummager do
  bunny = Bunny.new(ENV["RABBITMQ_URL"])
  channel = bunny.start.create_channel
  exch = Bunny::Exchange.new(channel, :topic, "published_documents")
  channel.queue("rummager_to_be_indexed").bind(exch, routing_key: "*.links")
  channel.queue("rummager_bulk_reindex").bind(exch, routing_key: "*.bulk.reindex")
  channel.queue("rummager_govuk_index").bind(exch, routing_key: "*.*")
end
