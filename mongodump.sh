#!/bin/bash

# Checking required environment variables
if [ -z "$MONGO_CONNECTION_STRING" ] || ([ -z "$MINIO_ENDPOINT" ] && [ -z "$S3_ENDPOINT" ]) || [ -z "$STORAGE_PATH" ]; then
    echo "Missing required environment variables!"
    exit 1
fi

# Mongodump
mongodump --uri="$MONGO_CONNECTION_STRING" --archive="/dump/archive" --gzip

# Configure AWS CLI with S3 or MinIO endpoint
if [ -n "$S3_ENDPOINT" ]; then
    aws configure set default.s3.endpoint_url "$S3_ENDPOINT"
else
    aws configure set default.s3.endpoint_url "$MINIO_ENDPOINT"
fi

# Upload to the given STORAGE_PATH
aws s3 cp /dump/archive s3://$STORAGE_PATH
