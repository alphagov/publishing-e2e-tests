# GOV.UK Publishing End-to-end Tests

A suite of end-to-end publishing tests that allow us to test functionality
across applications and services. The idea is that we test the sequence of
actions and movement of data throughout the system in a 'real world' context,
rather than stubbing services and making assumptions about responses. The tests
are browser tests (written in [RSpec](http://rspec.info/), using
[Capybara](https://github.com/teamcapybara/capybara)) that mimic the behaviour
of content editors.

Currently we have tests for [Specialist Publisher][specialist-publisher] and
[Travel Advice Publisher][travel-advice-publisher] (which require the
supporting applications and infrastructure, including Publishing API,
Content Store, Content Schemas, Router, Frontend, Static, MongoDB, Postgres,
Redis, RabbitMQ).

## Contents

- [How to run the tests](#how-to-run-tests)
- [What belongs in these tests](#what-belongs-in-these-tests)
- [Todo](#todo)
- [Gotchas](#gotchas)

## How to run the tests

### With Docker

Once you have [installed Docker][install-docker] you can build and run the test
suite with:

```
$ make
```

Running this command executes the following targets in order, which you can
choose to run separately to speed up development: `clone`, `build`, `start`,
`test` and `stop`.

For example, to run only the tests for the specialist publisher, you need only
do:

```bash
$ make -j4 clone
$ make build start test-specialist-publisher stop
```

#### Configuring Docker

We recommend that you configure Docker to use at least 4 CPUs with 4 GB of
memory, otherwise you may find the apps struggle to run well enough to pass the
tests.

<img src="docs/docker-configuration.png" width="300" />

#### More Docker help

There's further docker documentation for this project available in
[docs/docker.md](docs/docker.md).

### Without Docker

It is possible the run this suite without Docker however you will have to
set-up and configure each application in the stack and have them available
on `*.dev.gov.uk`. The tests can then be run with:

```
bundle exec rspec
```
## What belongs in these tests

These tests are for the purpose of testing that multiple applications speak to
each other, they are done from the user perspective and, in comparison to most
forms of testing, very slow and brittle.

Thus tests should be added here to test scenarios that cannot be tested under
other means. We want this to be the tip of of the
[testing pyramid][testing-pyramid] and not an example of a
[testing ice cream cone][testing-ice-cream-cone].

Rough guidelines for our testing approach is as follows:

- A component within an application: should be unit tested
- Multiple components within an application: should be integration tested
- Applications speaking directly to each: should be
  [contract tested][contract-tested], we've used [pact][pact]
- Multiple applications communicating together: contender for end-to-end tests

eg A test here is whether Specialist Publisher can publish a document, which
involves the following apps: Specialist Publisher, Publishing API,
Content Store, Router, and Specialist Frontend. Which could not be tested under
other means.

The approach to writing tests for here is:

- Follow the conventions of existing tests here
- Aim for one scenario per file
- Only test the "happy path" behaviour, not exceptional behaviour.
- Only describe things that should *happen*, not things that shouldn't.
- Write steps to be independent, not relying on the user being on a certain
  page.
- Avoid testing negatives; these are better tested in functional/unit tests.
- Avoid testing incidental behaviour (e.g. flash messages); these are better
  tested in functional/unit tests.

This list has been adapted from
[whitehall testing guide][whitehall-testing-guide] which is worth reading
for more testing insights.

## Todo

- Can we run the tests in parallel?
- Run the applications in rails production - requires mocking sign-on, and
  various env var changes
- Disable the virus scanner in asset-manager - perhaps with env var
- Explore and utilise [Docker healthcheck][docker-healthcheck]
- Reduce setup steps - can Specialist Publisher work without finders for instance?

## Gotchas

### WEBrick server seems to stop responding

We had a nasty bug with Router API where the web server seemed to stop
responding to any requests. This issue was experienced once the application
was upgraded to Rails 5.1 and Mongoid 6.1. The symptom was that any requests
to the server seemed to hang and never respond. The way this was resolved was
to switch from using WEBrick on Router API and instead
[use unicorn server][use-unicorn-pr].

[install-docker]: https://www.docker.com/community-edition
[specialist-publisher]: https://github.com/alphagov/specialist-publisher
[travel-advice-publisher]: https://github.com/alphagov/travel-advice-publisher
[docker-healthcheck]: https://docs.docker.com/engine/reference/builder/#healthcheck
[testing-pyramid]: https://martinfowler.com/bliki/TestPyramid.html
[testing-ice-cream-cone]: http://saeedgatson.com/the-software-testing-ice-cream-cone/
[contract-tested]: https://martinfowler.com/articles/consumerDrivenContracts.html
[pact]: https://docs.pact.io/
[whitehall-testing-guide]: https://github.com/alphagov/whitehall/blob/master/docs/testing.md
[use-unicorn-pr]: https://github.com/alphagov/router-api/pull/113
