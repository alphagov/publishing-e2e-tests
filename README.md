# GOV.UK Publishing End-to-end Tests

A suite of end-to-end publishing tests that allow us to test functionality
across applications and services. The idea is that we test the sequence of
actions and movement of data throughout the system in a 'real world' context,
rather than stubbing services and making assumptions about responses. The tests
are browser tests (written in [RSpec](http://rspec.info/), using
[Capybara](https://github.com/teamcapybara/capybara)) that mimic the behaviour
of content editors.

Tests are written against a variety of publishing applications to see which
apps are tested check the contents of the [spec](./spec) directory. To view
the details of all the apps involved check
[docker-compose.yml](./docker-compose.yml).

## How to run the tests

### With Docker

If this is your first time running the E2E project make sure you have [installed Docker][install-docker] and run:

```bash
$ bundle install
```

Build and run the test suite with:

```bash
$ make -j4
```

If it has been some time since you last worked on the E2E project it is recommended
to instead run:

```bash
$ make clean
$ make -j4
```

This will remove all your local apps, clone them, check them out to the latest
deployed-to-production branch. This has been a problem in the past due to stale
branches being checked out and either being unbuildable or causing false test
failures.

Running this command executes the following targets in order, which you can
choose to run separately to speed up development: `clean`, `clone`, `pull`, `build`,
`start`, `test` and `stop`.

For example, to run only the tests for the specialist publisher, you need only
do:

```bash
$ make -j4 clone
$ make pull build start test-specialist-publisher stop
```

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

### Without Docker

It is possible the run this suite without Docker however you will have to
set-up and configure each application in the stack and have them available
on `*.dev.gov.uk`. The tests can then be run with:

```
bundle exec rspec
```
## Failing Jenkins builds

We have detailed guidance to help with [debugging the reason][debugging-fails]
for a Jenkins failure inside the docs folder.

Additionally, if you are making a change to an E2E tested application which
requires a change one of these tests, we have
[detailed guidance][breaking-app-change] on how to achieve that.

[debugging-fails]: ./docs/jenkins-debugging-failures.md
[breaking-app-change]: ./docs/jenkins-breaking-changes.md

## Dealing with a flaky test

A key aim of these tests is to be as reliable as possible, however this can be
difficult - particularly early in a test's introduction - therefore we have a
[strategy](CONTRIBUTING.md#dealing-with-flaky-tests) to deal with flaky tests.

## Contributing

There is information on the coding standards, how to add tests and how to add
applications to this project in the [contributing guidelines](CONTRIBUTING.md).

## Gotchas

### WEBrick server seems to stop responding

We had a nasty bug with Router API where the web server seemed to stop
responding to any requests. This issue was experienced once the application
was upgraded to Rails 5.1 and Mongoid 6.1. The symptom was that any requests
to the server seemed to hang and never respond. The way this was resolved was
to switch from using WEBrick on Router API and instead
[use unicorn server][use-unicorn-pr].

### Page caching issue

We encountered an issue with Poltergeist caching a page that was used in two
different tests. This would result in whichever test ran second failing as
the excpected text would not show. We resolved this by clearing the
[Poltergeist page cache before each test][clear-page-cache-pr].

This issue could still potentially arise if a test visited the same page
multiple times in the same test and would likely need a similar solution
to be included as part of the test.

## Licence

[MIT License](LICENSE)

[install-docker]: https://www.docker.com/community-edition
[use-unicorn-pr]: https://github.com/alphagov/router-api/pull/113
[clear-page-cache-pr]: https://github.com/alphagov/publishing-e2e-tests/pull/204
