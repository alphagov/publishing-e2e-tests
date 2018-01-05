APPS = asset-manager content-store govuk-content-schemas government-frontend \
	publishing-api router router-api rummager \
	specialist-publisher static travel-advice-publisher collections-publisher \
	collections frontend publisher calendars \
	manuals-publisher manuals-frontend whitehall

DOCKER_COMPOSE_CMD = docker-compose -f docker-compose.yml
TEST_PROCESSES := 1

ifndef JENKINS_URL
  DOCKER_COMPOSE_CMD += -f docker-compose.development.yml
endif

ifndef TEST_ARGS
  TEST_ARGS = spec -o '--tag ~flaky --tag ~new'
endif

TEST_CMD = $(DOCKER_COMPOSE_CMD) run publishing-e2e-tests bundle exec parallel_rspec -n $(TEST_PROCESSES) $(TEST_ARGS)

all: clone build start test stop

$(APPS):
	bin/clone-app $@

clone: $(APPS)

kill:
	$(DOCKER_COMPOSE_CMD) kill
	$(DOCKER_COMPOSE_CMD) rm -f

build: kill
	COMPILE_ASSETS=true $(DOCKER_COMPOSE_CMD) build

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
	$(DOCKER_COMPOSE_CMD) run -e RUN_SEEDS_IN_PRODUCTION=true specialist-publisher bundle exec rake db:seed
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
	$(TEST_CMD) -o '--tag specialist_publisher --tag ~flaky --tag ~new'

test-travel-advice-publisher:
	$(TEST_CMD) -o '--tag travel_advice_publisher --tag ~flaky --tag ~new'

test-collections-publisher:
	$(TEST_CMD) -o '--tag collections_publisher --tag ~flaky --tag ~new'

test-publisher:
	$(TEST_CMD) -o '--tag publisher --tag ~flaky --tag ~new'

test-manuals-publisher:
	$(TEST_CMD) -o '--tag manuals_publisher --tag ~flaky --tag ~new'

test-frontend:
	$(TEST_CMD) -o '--tag frontend --tag ~flaky --tag ~new'

test-government-frontend:
	$(TEST_CMD) -o '--tag government_frontend --tag ~flaky --tag ~new'

stop: kill

.PHONY: all $(APPS) clone kill build setup start up test stop \
	test-specialist-publisher test-travel-advice-publisher \
	test-collections-publisher test-publisher test-manuals-publisher \
	test-frontend
