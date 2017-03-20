APPS = asset-manager content-store govuk-content-schemas government-frontend \
	publishing-api router router-api rummager specialist-frontend \
	specialist-publisher static travel-advice-publisher

TEST_CMD = docker-compose run publishing-e2e-tests bundle exec rspec --format d

all: clone build setup start test stop

$(APPS):
	bin/clone-app $@

clone: $(APPS)

down:
	docker-compose down

build: down
	docker-compose build

start:
	docker-compose up -d elasticsearch
	docker-compose run router-api bundle exec rake db:purge
	docker-compose run draft-router-api bundle exec rake db:purge
	docker-compose run content-store bundle exec rake db:purge
	docker-compose run draft-content-store bundle exec rake db:purge
	docker-compose run asset-manager bundle exec rake db:purge
	docker-compose run publishing-api bundle exec rake db:setup
	docker-compose run -e RUMMAGER_INDEX=all rummager bundle exec rake rummager:migrate_index
	docker-compose run publishing-api-worker rails runner 'Sidekiq::Queue.new.clear'
	docker-compose run publishing-api-worker bundle exec rails runner 'channel = Bunny.new.start.create_channel;Bunny::Exchange.new(channel, :topic, "test")'
	docker-compose run specialist-publisher bundle exec rake db:seed
	docker-compose run specialist-publisher bundle exec rake publishing_api:publish_finders
	docker-compose run travel-advice-publisher bundle exec rake db:seed
	docker-compose up -d

test:
	$(TEST_CMD)

stop: down

.PHONY: all clone build start test $(APPS)
