#!/bin/bash
source /home/fou/config.sh





URL="https://api.telegram.org/bot$TOKEN/sendMessage"

curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" > /dev/null
