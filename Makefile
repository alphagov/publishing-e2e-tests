APPS = asset-manager content-store govuk-content-schemas government-frontend \
	publishing-api router router-api rummager \
	specialist-publisher static travel-advice-publisher collections-publisher \
	collections frontend publisher calendars \
	manuals-publisher manuals-frontend whitehall

DOCKER_COMPOSE_CMD = docker-compose -f docker-compose.yml

ifndef JENKINS_URL
  DOCKER_COMPOSE_CMD += -f docker-compose.development.yml
endif

ifndef TEST_ARGS
  TEST_ARGS = --tag ~flaky --tag ~new
endif

TEST_CMD = $(DOCKER_COMPOSE_CMD) run publishing-e2e-tests bundle exec rspec $(TEST_ARGS)

all: clone build start test stop

$(APPS):
	bin/clone-app $@

clone: $(APPS)

kill:
	$(DOCKER_COMPOSE_CMD) kill
	$(DOCKER_COMPOSE_CMD) rm -f

build: kill
	$(DOCKER_COMPOSE_CMD) build

setup:
	$(DOCKER_COMPOSE_CMD) run publishing-e2e-tests bash -c 'find /app/tmp -name .keep -prune -o -type f -exec rm {} \;'
	$(DOCKER_COMPOSE_CMD) run router-api bundle exec rake db:purge
	$(DOCKER_COMPOSE_CMD) run draft-router-api bundle exec rake db:purge
	$(DOCKER_COMPOSE_CMD) run content-store bundle exec rake db:purge
	$(DOCKER_COMPOSE_CMD) run draft-content-store bundle exec rake db:purge
	$(DOCKER_COMPOSE_CMD) run asset-manager bundle exec rake db:purge
	$(DOCKER_COMPOSE_CMD) run publishing-api bundle exec rake db:setup
	$(DOCKER_COMPOSE_CMD) run -e RUMMAGER_INDEX=all rummager bundle exec rake rummager:create_all_indices
	$(DOCKER_COMPOSE_CMD) run publishing-api-worker rails runner 'Sidekiq::Queue.new.clear'
	# $(DOCKER_COMPOSE_CMD) run publishing-api-worker bundle exec rails runner 'channel = Bunny.new.start.create_channel;Bunny::Exchange.new(channel, :topic, "published_documents")'
	$(DOCKER_COMPOSE_CMD) run specialist-publisher bundle exec rake db:seed
	$(DOCKER_COMPOSE_CMD) run specialist-publisher bundle exec rake publishing_api:publish_finders
	$(DOCKER_COMPOSE_CMD) run travel-advice-publisher bundle exec rake db:seed
	$(DOCKER_COMPOSE_CMD) run manuals-publisher bundle exec rake db:seed
	$(DOCKER_COMPOSE_CMD) run collections-publisher bundle exec rake db:setup
	$(DOCKER_COMPOSE_CMD) run publisher bundle exec rake db:setup
	$(DOCKER_COMPOSE_CMD) run frontend bundle exec rake publishing_api:publish_special_routes
	$(DOCKER_COMPOSE_CMD) run whitehall bundle exec rake db:create db:purge db:setup
	$(DOCKER_COMPOSE_CMD) run publishing-e2e-tests bundle exec rake wait_for_router

up:
	$(DOCKER_COMPOSE_CMD) up -d

start: setup up

test:
	$(TEST_CMD)

test-specialist-publisher:
	$(TEST_CMD) --tag specialist_publisher

test-travel-advice-publisher:
	$(TEST_CMD) --tag travel_advice_publisher

test-collections-publisher:
	$(TEST_CMD) --tag collections_publisher

test-publisher:
	$(TEST_CMD) --tag publisher

test-manuals-publisher:
	$(TEST_CMD) --tag manuals_publisher

test-frontend:
	$(TEST_CMD) --tag frontend

test-government-frontend:
	$(TEST_CMD) --tag government_frontend

stop: kill

.PHONY: all $(APPS) clone kill build setup start up test stop \
	test-specialist-publisher test-travel-advice-publisher \
	test-collections-publisher test-publisher test-manuals-publisher \
	test-frontend
