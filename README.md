# GOV.UK Publishing End-to-end Tests

A suite of end-to-end publishing tests that allow us to test functionality across applications and services. The idea is that we test the sequence of actions and movement of data throughout the system in a 'real world' context, rather than stubbing services and making assumptions about responses. The tests are browser tests (written in Rspec, using Capybara) that mimic the behaviour of content editors.

Currently we only have tests for Specialist Publisher (and the supporting applications and infrastructure, including Publishing API, Content Store, Content Schemas, Router, Frontend, Static, MongoDB, Postgres, Redis, RabbitMQ). The tests run against a Docker orchestration of the various services.

## How to run the tests

The tests are run as part of the [Publishing end-to-end test docker](https://github.com/alphagov/publishing-e2e-docker) project. Install that project as per the README, and then you can run the end-to-end tests as follows:

```
docker-compose run publishing-e2e-tests bundle exec rspec
```

## Adding new tests

By default, the End-to-end Tests Docker project will run the tests in `publishing-e2e-docker/apps/publishing-e2e-tests` (which it clones from Github). To run your local branch of the tests, add a symlink:

```
rm -rf path/to/publishing-e2e-docker/apps/publishing-e2e-tests
ln -s path/to/publishing-e2e-tests path/to/publishing-e2e-docker/apps/publishing-e2e-tests
```
