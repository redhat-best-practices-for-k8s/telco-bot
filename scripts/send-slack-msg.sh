#!/bin/bash

# Slack Incoming Webhook URL
SLACK_WEBHOOK_URL=$1
JSON_FILE=$2
DAYS_BACK=$3

NUMBER_OF_RECORDS=$(cat $JSON_FILE | jq '.jobs | length')

MESSAGE="There have been $NUMBER_OF_RECORDS DCI jobs that have used the certsuite in the last $DAYS_BACK days.\n"

VERSIONS_BY_VALUE=$(cat $JSON_FILE | jq '.jobs | group_by(.tnf_version) | map({key: .[0].tnf_version, value: length})')

for row in $(echo "${VERSIONS_BY_VALUE}" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    VERSION=$(_jq '.key')
    COUNT=$(_jq '.value')

    MESSAGE="$MESSAGE\n Version: $VERSION -- Run Count: $COUNT"
done

echo $MESSAGE

DATA="{\"message\"   : \"${MESSAGE}\"}"

# Send the message to Slack
curl -X POST -H 'Content-type: application/json charset=UTF-8' --data "$DATA" $SLACK_WEBHOOK_URL