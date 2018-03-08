#!/bin/bash

export AWS_ACCESS_KEY_ID="********************"
export AWS_SECRET_ACCESS_KEY="****************************************"

AWS_ROUTE53_ZONEID="**************"
HOSTNAME="example.com"
TTL="60"
CURRENT_IP=`curl http://ifconfig.co/ 2>/dev/null`

result=`/usr/local/bin/aws route53 list-resource-record-sets --hosted-zone-id $AWS_ROUTE53_ZONEID --query "ResourceRecordSets[?Type == 'A']"`
AWS_IP="$( echo $result | jq -r '.[0].ResourceRecords[0].Value' )"

if [ $AWS_IP != $CURRENT_IP ]
then
	/usr/local/bin/aws route53 change-resource-record-sets --hosted-zone-id $AWS_ROUTE53_ZONEID --change-batch "{ \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"$HOSTNAME\", \"Type\": \"A\", \"TTL\": $TTL, \"ResourceRecords\": [ { \"Value\": \"$CURRENT_IP\" } ] } } ] }" > /dev/null 2>&1
	osascript -e "display notification \"Public IP has been updated: $AWS_IP\" with title \"Dynamic DNS\" "
fi

if [ $AWS_IP == $CURRENT_IP ]
then
	osascript -e "display notification \"Public IP Unchanged: $CURRENT_IP\" with title \"Dynamic DNS\" "
fi