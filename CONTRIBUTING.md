# Contributing

## Adding a new test

New tests that are added should be providing coverage of flows that touch more
than 2 applications in the GOV.UK stack.  More guidance can be found in the
[what-belongs-in-these-tests.md](docs/what-belongs-in-these-tests.md)

When adding a new scenario it has previously been valuable to consult with the
team responsible for maintaining the Publisher application that will be
affected.

Ideally any tests that have been added in should be written in such a way that
the risk of introducing flakiness, such as timeouts or rendering delays, is
reduced.

For example;
  - If adding a new service container make sure it has a healthcheck as part of
    the base Dockerfile or add one to the compose step.
  - When checking content is displayed on a frontend utilise the methods
    inside `RetryHelpers`

## Dealing with flakey tests

Sometimes these tests have been found to be sensitive to race hazards and other
timing issues that are not surfaced until they are run at scale.

When writing these tests we use techniques to try to avoid these race hazards
such as health checks and checking HTTP statuses in a loop.

Even with care, some of these race hazards will only become apparent once the
tests have been run 10s, even 100s of times.

When this occurs we recommend the following process to resolve a flakey test;

- Identify the flakey test
  - Tests that pass consistently unless run first or that sporadically timeout
  - Test fails more than once in a day with a consistent error
- Create a PR which skips the flakey test in the E2E suite e.g.
  ```ruby
  scenario "Change note on a Countryside Stewardship Grant", skip: true do
    given_there_is_a_published_countryside_stewardship_grant
    when_i_edit_it_with_a_change_note
    and_publish_it
    then_i_can_view_the_change_note_on_gov_uk
  end
  ```
  - In the commit outline the full failure message with any other information
    that would help when understanding why it was failing. E.g. was the test
    the first to run?
- In a separate PR provide a fix and re-enable the test
  - In the commits explain what the cause was, and why the change fixes that.
  - If no suitable fix can be found, then the test should be removed.
