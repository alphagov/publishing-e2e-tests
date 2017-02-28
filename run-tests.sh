#!/bin/sh
set -e

docker-compose run publishing-e2e-tests bundle exec rspec --format d
