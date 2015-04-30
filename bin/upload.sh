#!/bin/bash

file=$1
echo "Uploading $file to S3"

bucket="waffleio-takeout"
resource="/${bucket}/${file}"
contentType="application/zip"
dateValue=`TZ=utc date "+%a, %d %h %Y %T %z"`
stringToSign="PUT\n\n${contentType}\n${dateValue}\n${resource}"
s3Key=$WAFFLE_AWS_ACCESS_KEY_ID
s3Secret=$WAFFLE_AWS_SECRET_ACCESS_KEY
signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

curl \
  -k -X PUT -T $file \
  -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file} \
  | echo
