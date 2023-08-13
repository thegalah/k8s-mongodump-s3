#!/bin/bash

# Checking required environment variables
if [ -z "$MONGO_CONNECTION_STRING" ] || [ -z "$S3_OR_MINIO_ENDPOINT" ] || [ -z "$STORAGE_PATH" ]; then
    echo "Missing required environment variables!"
    exit 1
fi

# Setting the prefix for the dump files
DUMP_PREFIX=${DUMP_PREFIX:-dump}

# Creating the output directory
mkdir -p /dump/archive

# Building the file name with date
FILENAME="/dump/archive/${DUMP_PREFIX}_$(date +'%Y%m%d%H%M').gz"

# Running the mongodump command
mongodump --uri="$MONGO_CONNECTION_STRING" --archive="$FILENAME" --gzip --forceTableScan

# Configure AWS CLI with S3 or MinIO endpoint and optionally access keys
aws configure set default.s3.endpoint_url "$S3_OR_MINIO_ENDPOINT"
if [ -n "$ACCESS_KEY" ] && [ -n "$SECRET_KEY" ]; then
    aws configure set aws_access_key_id "$ACCESS_KEY"
    aws configure set aws_secret_access_key "$SECRET_KEY"
else
    NO_SIGN_REQUEST="--no-sign-request"
fi

# Upload to the given STORAGE_PATH
aws s3 cp $NO_SIGN_REQUEST "$FILENAME" s3://$STORAGE_PATH --endpoint-url "$S3_OR_MINIO_ENDPOINT"
