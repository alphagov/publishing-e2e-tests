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

## Manually running containers

- Run programs within containers using `docker-compose`:
  `docker-compose run publishing-e2e-tests bundle exec rspec`
- Get shell access to a given container: `docker-compose run specialist-frontend bash`
- Kill the containers and move on with your life: `docker-compose down`

## Gotchas

### Page caching issue

We encountered an issue with Poltergeist caching a page that was used in two
different tests. This would result in whichever test ran second failing as
the excpected text would not show. We resolved this by clearing the
[Poltergeist page cache before each test][clear-page-cache-pr].

This issue could still potentially arise if a test visited the same page
multiple times in the same test and would likely need a similar solution
to be included as part of the test.

[clear-page-cache-pr]: https://github.com/alphagov/publishing-e2e-tests/pull/204

### Docker disk space

Docker limits the amount of disk space it uses. This sometimes results in
rather opaque errors when you try and run tasks - generally related to
errors installing Mongo or Postres. One example is
`Moped::Errors::ConnectionFailure: Could not connect to a primary node for
replica set`.

The most reliable way to fix this is to find and remove unnecessary Docker
containers and images.

```
docker rmi $(docker images -f dangling=true -q)
docker volume rm $(docker volume ls -q -f dangling=true)
```

Docker for Mac will start comsuming vast amounts of CPU when it isn't given
enough RAM.   If you find the apps aren't booting within the 60 second timeout
then I'd recommend increasing the memory limit by at least 1GB.
