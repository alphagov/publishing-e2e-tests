APPS = asset-manager content-store govuk-content-schemas government-frontend \
	publishing-api router router-api rummager specialist-frontend \
	specialist-publisher static travel-advice-publisher

all: clone build start test stop

$(APPS):
	bin/clone-app $@

clone: $(APPS)

build:
	docker-compose down
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


# `make test` will run just the test command
#
# whereas if you run `make test tags=<comma separated list of test tags>` you
# can run particularly tagged tests
#
TEST_COMMAND = docker-compose run publishing-e2e-tests bundle exec rspec --format d
comma = ,
test:
ifdef tags
	$(TEST_COMMAND) --tag $(subst $(comma), --tag ,$(tags))
else
	$(TEST_COMMAND)
endif

stop:
	docker-compose down

.PHONY: all clone build start test $(APPS)
