# Troubleshooting

## Failing Jenkins builds

We have detailed guidance to help with [debugging the reason][debugging-fails]
for a Jenkins failure inside the docs folder.

Additionally, if you are making a change to an E2E tested application which
requires a change one of these tests, we have
[detailed guidance][breaking-app-change] on how to achieve that.

[debugging-fails]: ./jenkins-debugging-failures.md
[breaking-app-change]: ./jenkins-breaking-changes.md

## Dealing with a flaky test

A key aim of these tests is to be as reliable as possible, however this can be
difficult - particularly early in a test's introduction - therefore we have a
[strategy](./writing-tests.md#dealing-with-flaky-tests) to deal with flaky tests.

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

[use-unicorn-pr]: https://github.com/alphagov/router-api/pull/113
[clear-page-cache-pr]: https://github.com/alphagov/publishing-e2e-tests/pull/204
