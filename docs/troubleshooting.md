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

As this is a testing library, whose value correlates to the level of trust in
it, it is important to keep these tests as trustworthy as possible. A flaky
test can erode this trust.

Once you are confident a test is flakey, you can stop it failing the build while you investigate a potential fix. Use the `flaky: true` flag for this e.g.

```ruby
scenario "Change note on a Countryside Stewardship Grant", flaky: true do
  ...
end
```

Use [RetryHelpers][retry-helpers] to cope with pages that are slow to update, and [page-specific assertions][fb24c2] to ensure the assertions that follow are checking the page you expect.

[retry-helpers]: ./spec/support/retry_helpers.rb
[fb24c2]: https://github.com/alphagov/publishing-e2e-tests/commit/fb24c281c728424656410fb2e6c7d173e75ff2c3

## Manually running containers

- Run programs within containers using `docker-compose`:
  `docker-compose run publishing-e2e-tests bundle exec rspec`
- Get shell access to a given container: `docker-compose run specialist-frontend bash`
- Kill the containers and move on with your life: `docker-compose down`

## Gotchas

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
enough RAM. If you find the apps aren't booting within the 60 second timeout
then I'd recommend increasing the memory limit by at least 1GB.
