#!/bin/sh

echo "I: Checking if frontend vote app is available"

curl http://vote > /dev/null 2>&1


if [ $? -eq 0 ]
then
  echo "--------------------------------------------"
  echo "Vote app is available.....proceeding"
  echo "--------------------------------------------"
else
  echo "--------------------------------------------"
  echo "Vote app is not available.....aborting"
  echo "--------------------------------------------"
  exit 2
fi

echo "I: Launching integration test..."

curl -sS -X POST --data "vote=b" http://vote | grep -i erro

if [ $? -eq 0 ]
then
   echo "----------------------------"
   echo "INTEGRATION TEST FAILED"
   echo "----------------------------"
   exit 1
else
   echo "----------------------------"
   echo "INTEGRATION TEST PASSED"
   echo "----------------------------"
   exit 0
fi   
