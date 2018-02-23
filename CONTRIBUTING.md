# Publishing end-to-end tests contribution guide

This guide covers the basics for contributing to this project.

- [Coding/commit style](#codingcommit-style)
- [Adding new tests](#adding-new-tests)
- [Dealing with flaky tests](#dealing-with-flaky-tests)
- [Testing new applications](#testing-new-applications)

## Coding/commit style

Code and commits should be written in styles conforming to the GDS
[Ruby][ruby-styleguide] and [Git][git-styleguide] styleguides.

The feature tests are written in a style consistent with this article:
[How we write readable feature tests with rspec][readable-feature-tests].

[readable-feature-tests]: https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec
[ruby-styleguide]: https://github.com/alphagov/styleguides/blob/master/ruby.md
[git-styleguide]: https://github.com/alphagov/styleguides/blob/master/git.md

## Adding new tests

New tests that are added should be providing coverage of flows that touch more
than 2 applications in the GOV.UK stack. Further guidance can be found in
[what-belongs-in-these-tests.md](docs/what-belongs-in-these-tests.md).

When adding a new scenario it has previously been valuable to consult with the
team responsible for maintaining the Publisher application that will be
affected.

It is easy to accidentally introduce [flaky tests][] to this project given the
nature of end-to-end testing. It's expected that new tests being added will
have been run a number of times and that the developer will monitor them after
introduction so they're
[ready to act on a flaky test](#dealing-with-flaky-tests).

Common reasons for a flaky tests can include:

  - Applications not in a suitable state to be tested - Adding a Docker
    [healthcheck][docker-healthcheck] can alieviate this because it is syncronised
    on as part of the [wait_for_apps][docker_rake] rake task run during
    `make setup`
  - Checking conditions on pages that haven't yet been updated -
    [RetryHelpers][retry-helpers] can be used for this
  - Not waiting for a unique element to appear when moving between web pages.
    An example of this can be found in [fb24c2][fb24c2]

Tests should be tagged to the publishing and rendering applications they are
testing using [rspec tags][] to only run tests that concern that application.
This is because the tests are slow and doing this can limit the impact of
a flaky test.

When adding a new test into the project it can also be tagged with `new: true`, tests that are tagged with `new` or `flaky` are executed in the new/flaky stage. This stage runs separately from the existing tests and will not fail the overall build. If this stage fails a notification is posted to the `#end-to-end-tests` slack channel to provide easy monitoring.
This allows for a chance to build confidence in new tests without impacting the current suite should there be any flakiness as they run at a much higher volume than when being developed originally.

[flaky tests]: https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
[docker-healthcheck]: https://docs.docker.com/engine/reference/builder/#healthcheck
[retry-helpers]: ./spec/support/retry_helpers.rb
[rspec tags]: https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/tag-option
[docker_rake]: ./lib/tasks/docker.rake
[fb24c2]: https://github.com/alphagov/publishing-e2e-tests/commit/fb24c281c728424656410fb2e6c7d173e75ff2c3

## Dealing with flaky tests

Sometimes these tests have been found to be sensitive to race hazards and other
timing issues that are not surfaced until they are run at scale. Even with
care, some of these race hazards will only become apparent once the tests have
been run 10s - or even 100s - of times.

As this is a testing library, whose value correlates to the level of trust in
it, it is important to keep these tests as trustworthy as possible. A flaky
test can erode this trust.

### Think a test might be flaky?

- First step is to be able to confidently say that test is flaky:
  - For a flaky test it should be passing and failing given the same
    environment
  - If the test is failing consistently it might be a sign that something
    different in the stack is broken
- Next we want to stop the test failing for users of the suite:
  - Create a PR which marks the test as flaky in this repository e.g.
    ```ruby
    scenario "Change note on a Countryside Stewardship Grant", flaky: true do
      ...
    end
    ```
  - In the commit outline the full failure message with any other information
    that would help when understanding why it was failing. E.g. was the test
    the first to run?

### Fixing a flaky test

The challenge with fixing a flaky test is to be confident that what you have
done has resolved the issue, and that you can convince someone reviewing the
fix that your changes resolve this. It can be valuable to point to a number of successful test runs on the flaky stage.

It is therefore useful to use the commit message as a place to explain exactly
what the cause of the flaky result is and how the changes introduced resolve
that.

If a flaky test cannot be fixed it should be removed from the suite.

## Testing new applications

To test new applications you will need to follow the
[process for adding containers](docs/docker.md#adding-containers)
to the [docker compose][].

Once these are running inside of docker you should follow the
[adding new tests](#adding-new-tests) process.

When adding a new app you should add a RSpec tag to associate tests with that
app, and a step in the Makefile to run those tests. E.g. if you were adding
whitehall as an app you would tag the tests with `whitehall: true` and create a
step in the make file called `test-whitehall`.

To run against specific revisions of the applications (such as commits and branches),
you'll need to add an entry for the application being tested to the apps array in
the Jenkinsfile.

Once you have merged your tests into this repository and removed the `new: true` 
tag, because you are confident in them, you'll want to enable the tests to be
run on every commit to the applications repositories.  The Jenkinsfile for 
most applications uses the `buildProject` which  has a `publishingE2ETests` 
parameter that enables this functionality. The Publisher Jenkinsfile has an
[example of enabling][publishing-jenkinsfile] the E2E tests, 
and using the `PUBLISHING_E2E_TESTS_COMMAND` variable to only run
`publisher: true` tagged specs.

[docker compose]: https://docs.docker.com/compose/
[publishing-jenkinsfile]: https://github.com/alphagov/publisher/commit/712563d5d3e72685b1848bb61ea6cfc28b3449c3 
