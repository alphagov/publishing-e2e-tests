#!/bin/sh
set -e

./clone-apps.sh
./start-docker.sh
sleep 2
./run-tests.sh
./stop-docker.sh
