# Adding new apps

1. Create a `Dockerfile` in the repository of the app you want to add.
1. Edit the `Makefile` to include the repository for the app.
1. Define the service and its relationship to other services in `docker-compose.yml`.
1. Create a `test-<app>` step in the Makefile to run tests tagged with `<app>: true`.
1. Add a Docker [healthcheck][docker-healthcheck] to check the app is ready to do work.
    - The [wait_for_apps][docker_rake] stage of the build will block until the healthcheck comes back as OK.
1. Add the app to the [Jenkinsfile](https://github.com/alphagov/publishing-e2e-tests/blob/main/Jenkinsfile) to support building with specific commits.
1. Add Publishing E2E tests as a required check on the app repo ([example](https://github.com/alphagov/publisher/commit/712563d5d3e72685b1848bb61ea6cfc28b3449c3)).

[docker-healthcheck]: https://docs.docker.com/engine/reference/builder/#healthcheck
[docker_rake]: ../lib/tasks/docker.rake
