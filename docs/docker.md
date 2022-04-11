# Docker configuration

## Usage

- Run programs within containers using `docker-compose`:
  `docker-compose run publishing-e2e-tests bundle exec rspec`
- Get shell access to a given container: `docker-compose run specialist-frontend bash`
- Kill the containers and move on with your life: `docker-compose down`

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
