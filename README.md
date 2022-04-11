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

### Testing with a branch

If you need to run the tests against a branch of an application other than
deployed-to-production you need to explicitly build it as below:

```bash
$ make -j4 clone pull PUBLISHER_COMMITISH=your_branch
$ docker-compose build publisher
$ make start test-publisher stop
```

When making changes to an application you will need to rebuild the image before
the new version will be used.

```bash
$ docker-compose build publisher
```

When you have finished testing against your branch version and want to switch back
to the deployed-to-production version you will need to untag the built image before
you can re-pull.  The `clean_docker` make recipe will untag all locally built images.

```bash
$ make clean_docker
$ make pull
```

See [docs/docker.md](docs/docker.md) for more information
configuring/troubleshooting docker.

## Licence

[MIT License](LICENSE)

[install-docker]: https://www.docker.com/community-edition
