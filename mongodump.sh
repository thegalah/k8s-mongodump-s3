#!/bin/bash

# Checking required environment variables
if [ -z "$MONGO_CONNECTION_STRING" ] || [ -z "$S3_OR_MINIO_ENDPOINT" ] || [ -z "$STORAGE_PATH" ]; then
    echo "Missing required environment variables!"
    exit 1
fi

# Creating the output directory
mkdir -p /dump/archive

# Building the file name with date
FILENAME="/dump/archive/dump_$(date +'%Y%m%d%H%M').gz"

# Building the mongodump command
DUMP_CMD="mongodump --uri=\"$MONGO_CONNECTION_STRING\" --archive=\"$FILENAME\" --gzip --forceTableScan"

if [ -n "$MONGO_USERNAME" ]; then
    DUMP_CMD+=" --username=\"$MONGO_USERNAME\""
fi

if [ -n "$MONGO_PASSWORD" ]; then
    DUMP_CMD+=" --password=\"$MONGO_PASSWORD\""
fi

if [ -n "$MONGO_DATABASE" ]; then
    DUMP_CMD+=" --db=\"$MONGO_DATABASE\""
fi

if [ -n "$MONGO_COLLECTION" ]; then
    DUMP_CMD+=" --collection=\"$MONGO_COLLECTION\""
fi

if [ -n "$MONGO_QUERY" ]; then
    DUMP_CMD+=" --query=\"$MONGO_QUERY\""
fi

# Running the mongodump command
eval $DUMP_CMD

# Configure AWS CLI with S3 or MinIO endpoint
aws configure set aws_access_key_id "$ACCESS_KEY"
aws configure set aws_secret_access_key "$SECRET_KEY"
aws configure set default.s3.endpoint_url "$S3_OR_MINIO_ENDPOINT"

# Upload to the given STORAGE_PATH
aws s3 cp "$FILENAME" s3://$STORAGE_PATH
