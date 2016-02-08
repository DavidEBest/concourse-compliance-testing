#!/bin/bash

COUNTER=0
COUNT=$(cat targets.json | jq '.targets[] .url' | wc -l)

zap-cli start --start-options '-config api.disablekey=true'

while [ $COUNTER -lt $COUNT ]; do
  NAME=$(cat targets.json | jq ".targets[${COUNTER}] .name")
  TARGET=$(cat targets.json | jq ".targets[${COUNTER}] .url")

  echo Scanning $NAME: $TARGET
  zap-cli open-url ${TARGET}
  zap-cli spider ${TARGET}
  zap-cli active-scan -s all -r ${TARGET}
  zap-cli alerts -l Informational -f json > results/${NAME}.json

  let COUNTER+=1
done

zap-cli shutdown

python ./s3upload.py

exit 0
