#!/bin/bash

cd e2e

#docker-compose down

#sleep 10

docker-compose build
docker-compose up -d

docker-compose ps


sleep 15

#docker-compose run --rm e2e
docker-compose run --rm e2e

docker-compose down
