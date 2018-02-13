# Docker

## Usage

- Run programs within containers using `docker-compose`:
  `docker-compose run publishing-e2e-tests bundle exec rspec`
- Get shell access to a given container: `docker-compose run specialist-frontend bash`
- Kill the containers and move on with your life: `docker-compose down`

## Configuration

We recommend that you configure Docker to use at least 4 CPUs with 4 GB of
memory, otherwise you may find the apps struggle to run well enough to pass the
tests.

<img src="docker-configuration.png" width="300" />

## Adding containers

- Create a `Dockerfile` in the repository of the app you want to add.
- Edit `Makefile` to include the repository for the app.
- Define the service and its relationship to other services in
  `docker-compose.yml`

## Local apps

If you want to use a local version of an application, symlink your
directory into `./apps`. For example:

```
rm -rf apps/publishing-api
ln -s path/to/publishing-api apps/publishing-api
```

## Quirks

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
