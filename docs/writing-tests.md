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

Tips for writing tests:

  - Add a Docker [healthcheck][docker-healthcheck] to check the app is in a suitable state to be tested. The [wait_for_apps][docker_rake] stage of the build will block until the healthcheck comes back as OK.
  - Use [RetryHelpers][retry-helpers] to cope with pages that are slow to update, and [page-specific assertions][fb24c2] to ensure the assertions that follow are checking the page you expect.

Tests should be tagged to the publishing and rendering applications they are
testing using [rspec tags][] to only run tests that concern that application.

Use `new: true` when adding a new test, until it has been run for a sufficiently long period for you to be confident it is not flakey. Tests that are tagged with `new` will not fail the overall build.

### Tips
- Starting up the docker containers is _slow_. Use `binding.pry` to pry into your test and use the console to debug and write your test. Additionally, `save_screenshot('filename.png')` will help you see what is going on.
- If you are relying on code in a repo, ensure that the code is in the `deployed-to-production` branch. If not, see main README for guidance on running the tests against a different branch.

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
