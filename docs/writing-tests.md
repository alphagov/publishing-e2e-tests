# Writing tests

This guide covers the basics for contributing to this project.

- [Coding style](#coding-style)
- [Adding new tests](#adding-new-tests)
- [Dealing with flaky tests](#dealing-with-flaky-tests)
- [Testing new applications](#testing-new-applications)

## Coding style

The feature tests are written in a style consistent with this article:
[How we write readable feature tests with rspec][readable-feature-tests].

[readable-feature-tests]: https://about.futurelearn.com/blog/how-we-write-readable-feature-tests-with-rspec

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

### Tips
- Starting up the docker containers is _slow_. Use `binding.pry` to pry into your test and use the console to debug and write your test. Additionally, `save_screenshot('filename.png')` will help you see what is going on.
- If you are relying on code in a repo, ensure that the code is in the `deployed-to-production` branch. If not, see main README for guidance on running the tests against a different branch.

[flaky tests]: https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
[docker-healthcheck]: https://docs.docker.com/engine/reference/builder/#healthcheck
[retry-helpers]: ./spec/support/retry_helpers.rb
[rspec tags]: https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/tag-option
[docker_rake]: ./lib/tasks/docker.rake
[fb24c2]: https://github.com/alphagov/publishing-e2e-tests/commit/fb24c281c728424656410fb2e6c7d173e75ff2c3

## Dealing with flaky tests

As this is a testing library, whose value correlates to the level of trust in
it, it is important to keep these tests as trustworthy as possible. A flaky
test can erode this trust.

Once you are confident a test is flakey, you can stop it failing the build while you investigate a potential fix. Use the `flaky: true` flag for this e.g.

```ruby
scenario "Change note on a Countryside Stewardship Grant", flaky: true do
  ...
end
```

## Testing new applications

- Create a `Dockerfile` in the repository of the app you want to add.
- Edit `Makefile` to include the repository for the app.
- Define the service and its relationship to other services in
  `docker-compose.yml`

Now follow the [adding new tests](#adding-new-tests) process.

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
