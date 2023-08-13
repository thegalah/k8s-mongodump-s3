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
DUMP_OPTIONS=(--uri="$MONGO_CONNECTION_STRING" --archive="$FILENAME" --gzip --forceTableScan)

if [ -n "$MONGO_USERNAME" ]; then
    DUMP_OPTIONS+=(--username="$MONGO_USERNAME")
fi

if [ -n "$MONGO_PASSWORD" ]; then
    DUMP_OPTIONS+=(--password="$MONGO_PASSWORD")
fi

if [ -n "$MONGO_DATABASE" ]; then
    DUMP_OPTIONS+=(--db="$MONGO_DATABASE")
fi

if [ -n "$MONGO_COLLECTION" ]; then
    DUMP_OPTIONS+=(--collection="$MONGO_COLLECTION")
fi

if [ -n "$MONGO_QUERY" ]; then
    DUMP_OPTIONS+=(--query="$MONGO_QUERY")
fi

# Running the mongodump command
mongodump "${DUMP_OPTIONS[@]}"

# Conditionally configure AWS CLI with access and secret keys
if [ -n "$ACCESS_KEY" ] && [ -n "$SECRET_KEY" ]; then
    aws configure set aws_access_key_id "$ACCESS_KEY"
    aws configure set aws_secret_access_key "$SECRET_KEY"
fi

# Configure the endpoint
aws configure set default.s3.endpoint_url "$S3_OR_MINIO_ENDPOINT"

# Upload to the given STORAGE_PATH
aws s3 cp "$FILENAME" s3://$STORAGE_PATH
