#!/bin/sh
set -e

docker-compose down
docker-compose build

# Elastic Search takes about 10 seconds to be available after the container has
# started. When HEALTHCHECK (https://docs.docker.com/engine/reference/builder/#healthcheck)
# is available on ElasticSearch we can use that instead.
docker-compose up -d elasticsearch
set +e
wget --retry-connrefused --tries=10 -q --wait=3 --spider http://localhost:9200
set -e

docker-compose run -e RUMMAGER_INDEX=all rummager bundle exec rake rummager:migrate_index
docker-compose run router-api bundle exec rake db:purge
docker-compose run draft-router-api bundle exec rake db:purge
docker-compose run content-store bundle exec rake db:purge
docker-compose run draft-content-store bundle exec rake db:purge
docker-compose run publishing-api bundle exec rake db:setup
docker-compose run publishing-api-worker rails runner 'Sidekiq::Queue.new.clear'
docker-compose run publishing-api-worker bundle exec rails runner 'channel = Bunny.new.start.create_channel;Bunny::Exchange.new(channel, :topic, "test")'
docker-compose run specialist-publisher bundle exec rake db:seed
docker-compose run specialist-publisher bundle exec rake publishing_api:publish_finders
docker-compose run travel-advice-publisher bundle exec rake db:seed
docker-compose run asset-manager bundle exec rake db:purge
docker-compose up -d
