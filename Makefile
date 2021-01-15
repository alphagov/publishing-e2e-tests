APPS = asset-manager content-store govuk-content-schemas government-frontend \
	publishing-api router router-api search-api \
	specialist-publisher static travel-advice-publisher collections-publisher \
	collections frontend publisher  \
	manuals-publisher manuals-frontend whitehall content-tagger \
	contacts-admin finder-frontend email-alert-api

RUBY_VERSION = `cat .ruby-version`
DOCKER_RUN = docker run --rm -v `pwd`:/app ruby:$(RUBY_VERSION)
DOCKER_COMPOSE_CMD = docker-compose -f docker-compose.yml
TEST_PROCESSES := 1

ifndef JENKINS_URL
  DOCKER_COMPOSE_CMD += -f docker-compose.development.yml
endif

ifndef TEST_ARGS
	ifdef FLAKY_ONLY
		FLAKEY_ONLY = true
	endif

	ifdef FLAKEY_ONLY
		TAGS = --tag flaky --tag flakey
	else
		TAGS = --tag ~flaky --tag ~flakey --tag ~new
	endif

  TEST_ARGS = spec -o '$(TAGS) $(EXTRA_TAGS)'
endif

TEST_CMD = $(DOCKER_COMPOSE_CMD) run publishing-e2e-tests bundle exec parallel_rspec -n $(TEST_PROCESSES) $(TEST_ARGS)

all:
	$(MAKE) clone
	$(MAKE) stop
	$(MAKE) clean_docker
	$(MAKE) pull build
	$(MAKE) start
	$(MAKE) test
	$(MAKE) stop

$(APPS):
	bin/clone-app $@

clone: $(APPS)

kill:
	$(DOCKER_COMPOSE_CMD) kill
	$(DOCKER_COMPOSE_CMD) rm -f

build: kill
	$(DOCKER_COMPOSE_CMD) build --pull diet-error-handler publishing-e2e-tests $(APPS_TO_BUILD)

setup_dependencies:
	$(DOCKER_COMPOSE_CMD) up -d elasticsearch6 mongo mysql postgres rabbitmq redis
	bundle exec rake docker:wait_for_dbs
	$(MAKE) setup_dbs
	bundle exec rake docker:wait_for_rabbitmq
	$(MAKE) setup_queues

setup_apps:
	bundle exec rake docker:wait_for_publishing_api
	$(MAKE) contacts_admin_seed
	$(MAKE) publish_routes
	$(MAKE) populate_end_to_end_test_data_from_whitehall
	$(DOCKER_COMPOSE_CMD) run --rm publishing-e2e-tests bundle exec rake govuk:wait_for_router
	bundle exec rake docker:wait_for_apps

setup_dbs: router_setup content_store_setup asset_manager_setup \
	publishing_api_setup travel_advice_setup whitehall_setup \
	content_tagger_setup manuals_publisher_setup specialist_publisher_setup \
	publisher_setup collections_publisher_setup search_api_setup \
	contacts_admin_setup email_alert_api_setup

router_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps router-api bundle exec rake db:reset
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps draft-router-api bundle exec rake db:reset

content_store_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps content-store bundle exec rake db:reset
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps draft-content-store bundle exec rake db:reset

asset_manager_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps asset-manager bundle exec rake db:reset

publishing_api_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps publishing-api bundle exec rake db:reset

travel_advice_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps travel-advice-publisher bundle exec rake db:seed

whitehall_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps whitehall-admin bundle exec rake db:reset

content_tagger_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps content-tagger bundle exec rake db:reset

manuals_publisher_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps manuals-publisher bundle exec rake db:seed

specialist_publisher_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps specialist-publisher env RUN_SEEDS_IN_PRODUCTION=true bundle exec rake db:seed

publisher_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps publisher bundle exec rake db:reset

collections_publisher_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps collections-publisher bundle exec rake db:reset

search_api_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps search-api env SEARCH_INDEX=all bundle exec rake search:create_all_indices

email_alert_api_setup:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps email-alert-api bundle exec rake db:reset

wait_for_whitehall_admin:
	bundle exec rake docker:wait_for_whitehall_admin

contacts_admin_setup:
	# Because someone made the rather bizarre decision that Whitehall needs to be
	# running to seed the contacts admin database we have to do this in 2-steps
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps contacts-admin bundle exec rake db:drop db:schema:load_if_ruby db:structure:load_if_sql

contacts_admin_seed: wait_for_whitehall_admin
	# Contacts Admin seeds from the organisations API, which is rendered by
	# Collections, which gets its data from Search API, which gets indexed by
	# Whitehall.
	$(DOCKER_COMPOSE_CMD) exec -T whitehall-admin bundle exec rake search:index:organisations
	$(DOCKER_COMPOSE_CMD) exec -T collections-publisher bundle exec rake publishing_api:publish_organisations_api_route

	$(DOCKER_COMPOSE_CMD) exec -T contacts-admin bundle exec rake db:seed

setup_queues:
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps publishing-api bundle exec rake setup_exchange
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps publishing-api-worker rails runner 'Sidekiq::Queue.new.clear'
	$(DOCKER_COMPOSE_CMD) run --rm --no-deps search-api-worker bundle exec rake message_queue:create_queues

publish_routes: publish_search_api publish_specialist publish_frontend publish_contacts_admin publish_whitehall publish_collections_publisher

publish_search_api:
	$(DOCKER_COMPOSE_CMD) exec -T search-api bundle exec rake publishing_api:publish_special_routes
	$(DOCKER_COMPOSE_CMD) exec -T search-api bundle exec rake publishing_api:publish_supergroup_finders

publish_specialist:
	$(DOCKER_COMPOSE_CMD) exec -T specialist-publisher bundle exec rake publishing_api:publish_finders

publish_frontend:
	$(DOCKER_COMPOSE_CMD) exec -T frontend bundle exec rake publishing_api:publish_special_routes
	$(DOCKER_COMPOSE_CMD) exec -T frontend bundle exec rake publishing_api:publish_calendars

publish_collections_publisher:
	$(DOCKER_COMPOSE_CMD) exec -T collections-publisher bundle exec rake publishing_api:publish_organisations_api_route
	$(DOCKER_COMPOSE_CMD) exec -T collections-publisher bundle exec rake publishing_api:publish_special_routes

publish_contacts_admin:
	$(DOCKER_COMPOSE_CMD) exec -T contacts-admin bundle exec rake finders:publish

publish_whitehall:
	$(DOCKER_COMPOSE_CMD) exec -T whitehall-admin bundle exec rake publishing_api:publish_special_routes

populate_end_to_end_test_data_from_whitehall:
	$(DOCKER_COMPOSE_CMD) exec -T whitehall-admin bundle exec rake taxonomy:populate_end_to_end_test_data

clean_apps:
	$(DOCKER_RUN) bash -c 'rm -rf /app/apps/*'

clean_docker:
	bundle exec rake docker:remove_built_app_images

clean_tmp:
	$(DOCKER_RUN) bash -c 'find /app/tmp -not -name .keep -type f -delete'
	$(DOCKER_RUN) bash -c 'find /app/tmp -depth -empty -type d -delete'

clean: clean_tmp clean_apps clean_docker

up:
	$(DOCKER_COMPOSE_CMD) up -d

pull:
	$(DOCKER_COMPOSE_CMD) pull --parallel --ignore-pull-failures

start:
	$(MAKE) setup_dependencies
	$(MAKE) up
	$(MAKE) setup_apps

test:
	$(TEST_CMD)

test-specialist-publisher:
	EXTRA_TAGS='--tag specialist_publisher' $(MAKE) test

test-travel-advice-publisher:
	EXTRA_TAGS='--tag travel_advice_publisher' $(MAKE) test

test-collections-publisher:
	EXTRA_TAGS='--tag collections_publisher' $(MAKE) test

test-publisher:
	EXTRA_TAGS='--tag publisher' $(MAKE) test

test-manuals-publisher:
	EXTRA_TAGS='--tag manuals_publisher' $(MAKE) test

test-collections:
	EXTRA_TAGS='--tag collections' $(MAKE) test

test-finder-frontend:
	EXTRA_TAGS='--tag finder_frontend' $(MAKE) test

test-frontend:
	EXTRA_TAGS='--tag frontend' $(MAKE) test

test-government-frontend:
	EXTRA_TAGS='--tag government_frontend' $(MAKE) test

test-content-tagger:
	EXTRA_TAGS='--tag content_tagger' $(MAKE) test

test-contacts-admin:
	EXTRA_TAGS='--tag contacts_admin' $(MAKE) test

test-whitehall:
	EXTRA_TAGS='--tag whitehall' $(MAKE) test

stop: kill

.PHONY: all $(APPS) clone kill build start up test stop \
	test-specialist-publisher test-travel-advice-publisher \
	test-collections-publisher test-publisher test-manuals-publisher \
	test-frontend test-content-tagger test-contacts-admin test-finder-frontend \
	router_setup content_store_setup asset_manager_setup \
	publishing_api_setup travel_advice_setup whitehall_setup \
	content_tagger_setup manuals_publisher_setup \
	specialist_publisher_setup publisher_setup collections_publisher_setup \
	search_api_setup publish_search_api publish_specialist publish_frontend \
	publish_contacts_admin publish_whitehall setup_dbs setup_queues \
	wait_for_whitehall_admin contacts_admin_setup contact_admin_seed pull \
	clean_apps clean_docker clean_tmp clean setup_apps setup_dependencies
