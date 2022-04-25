#!/bin/bash

cd vote/integration

echo "I: creating environment to run integration tests..."

docker-compose build
docker-compose up -d

echo "I: Launching Integration Test..."

docker-compose run --rm integration /test/tests.sh

if [ $? -eq 0 ]
then
  echo "----------------------------------"
  echo "Integration Tests Passed......"
  echo "----------------------------------"
  docker-compose down
  cd ..
  exit 0
else
  echo "----------------------------------"
  echo "Integration Tests Failed......"
  echo "----------------------------------"
  echo ""
  docker-compose down
  cd ..
  exit 1
fi

