# GOV.UK Publishing End-to-end Tests

A suite of end-to-end tests for publisher user journeys. The tests are written in [RSpec](http://rspec.info/) / [Capybara](https://github.com/teamcapybara/capybara) and mimic the behaviour of content editors in a web browser, using [headless Chrome](https://github.com/alphagov/publishing-e2e-tests/blob/2044d7eb3c00194d9fd6d1452849b7afc77b3608/spec/spec_helper.rb#L119).

> **Warning: this repo is DEPRECATED as of [RFC 128 (Continuous Deployment)](https://github.com/alphagov/govuk-rfcs/blob/main/rfc-128-continuous-deployment.md#delete-publishing-e2e-tests)**. The tests are slow and brittle and do not run in a realistic GOV.UK environment. Do not add any new tests to this repo.
>
> [Read about alternatives to Publishing End-to-end Tests](docs/writing-tests.md#what-belongs-here).

## Technical documentation

To see which apps are tested check the contents of the [spec](./spec) directory.

To view the details of all the apps involved check [docker-compose.yml](./docker-compose.yml).

### Before running the tests

If this is your first time running the E2E project make sure you have [installed Docker][install-docker] and run:

```bash
$ bundle install
```

_We recommend that you configure Docker to use at least 4 CPUs with 6 GB of memory, otherwise you may find the apps struggle to run well enough to pass the tests._

If it has been some time since you last worked on the E2E project it is recommended to run:

```bash
$ make clean
```

This will remove all your local apps (in `./apps/`), clone them again and check them out to the deployed-to-production branch (in case one of the apps is on an old branch).

### Running the test suite

Build and run the test suite with:

```bash
$ make -j4
```

### Running a single test

Running `make` executes the following targets in order, which you can
choose to run separately to speed up development: `clone`, `pull`, `build`,
`start`, `test` and `stop`.

For example, to run only the tests for the specialist publisher, you need only
do:

```bash
$ make -j4 clone
$ make pull build start test-specialist-publisher stop
```

## Further documentation

- [Getting a breaking app change through Jenkins](docs/jenkins-breaking-changes.md)
- [Debugging Jenkins failures](docs/jenkins-debugging-failures.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Writing tests](docs/writing-tests.md)
- [Testing with a branch](docs/testing-with-a-branch.md)
- [Adding new apps](docs/adding-new-apps.md)

## Licence

[MIT License](LICENSE)

[install-docker]: https://www.docker.com/community-edition
