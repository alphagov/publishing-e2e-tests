#!/bin/sh
set -e

./clone-apps.sh
./start-docker.sh
sleep 5
./run-tests.sh
./stop-docker.sh
