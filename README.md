# GOV.UK Publishing End-to-end Tests

A suite of end-to-end publishing tests that allow us to test functionality
across applications and services. The idea is that we test the sequence of
actions and movement of data throughout the system in a 'real world' context,
rather than stubbing services and making assumptions about responses. The tests
are browser tests (written in [RSpec](http://rspec.info/), using
[Capybara](https://github.com/teamcapybara/capybara)) that mimic the behaviour
of content editors.

## Technical documentation

To see which apps are tested check the contents of the [spec](./spec) directory.

To view the details of all the apps involved check [docker-compose.yml](./docker-compose.yml).

### Before running the tests

If this is your first time running the E2E project make sure you have [installed Docker][install-docker] and run:

```bash
$ bundle install
```

If it has been some time since you last worked on the E2E project it is recommended to run:

```bash
$ make clean
```

This will remove all your local apps, clone them, check them out to the latest
deployed-to-production branch. This has been a problem in the past due to stale
branches being checked out and either being unbuildable or causing false test
failures.

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

- [Docker configuration and troubleshooting](docs/docker.md)
- [Getting a breaking app change through Jenkins](docs/jenkins-breaking-changes.md)
- [Debugging Jenkins failures](docs/jenkins-debugging-failures.md)
- [Troubleshooting](docs/troubleshooting.md)
- [What belongs in publishing-e2e-tests](docs/what-belongs-in-these-tests.md)
- [Writing tests](docs/writing-tests.md)
- [Testing with a branch](docs/testing-with-a-branch.md)

## Licence

[MIT License](LICENSE)

[install-docker]: https://www.docker.com/community-edition
