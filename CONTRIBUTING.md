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

  - Applications not in a suitable state to be tested - Docker
    [healthcheck][docker-healthcheck] can be useful
  - Checking conditions on pages that haven't yet been updated -
    [RetryHelpers][retry-helpers] can be used for this

Tests should be tagged to the publishing and rendering applications they are
testing using [rspec tags][] to only run tests that concern that application.
This is because the tests are slow and doing this can limit the impact of
introducing a flaky test.

[flaky tests]: https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
[docker-healthcheck]: https://docs.docker.com/engine/reference/builder/#healthcheck
[retry-helpers]: ./spec/support/retry_helpers.rb
[rspec tags]: https://relishapp.com/rspec/rspec-core/v/3-7/docs/command-line/tag-option

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
  - Create a PR which skips the flaky test in this repository e.g.
    ```ruby
    scenario "Change note on a Countryside Stewardship Grant", skip: true do
      ...
    end
    ```
  - In the commit outline the full failure message with any other information
    that would help when understanding why it was failing. E.g. was the test
    the first to run?

### Fixing a flaky test

The challenge with fixing a flaky test is to be confident that what you have
done has resolved the issue, and that you can convince someone reviewing the
fix that your changes resolve this.

It is therefore useful to use the commit message as a place to explain exactly
what the cause of the flaky result is and how the changes introduced resolve
that.

If a flaky test cannot be fixed it should be removed from the suite.

## Testing new applications

To test new applications you have to follow a similar process to
[adding new tests](#adding-new-tests) however you will also need to configure
this application to run the application through [docker compose][]

A brief guide to setting this up is available in
[docs/docker.md](docs/docker.md#adding-containers).

[docker compose]: https://docs.docker.com/compose/
