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

# Function to run mongodump command
run_mongodump() {
    output="$(mongodump --uri="$MONGO_CONNECTION_STRING" --archive="$FILENAME" --gzip --forceTableScan --quiet 2>&1)"
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        echo -e "Error running mongodump: $output"
    fi
    return $EXIT_CODE
}

# Attempt to run the mongodump command if it fails
RETRIES=7
DELAY=1 # Initial delay in seconds
for i in $(seq 1 $RETRIES); do
    run_mongodump
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        break
    else
        echo "mongodump failed, attempt $i of $RETRIES"
        rm -f "$FILENAME" # Removing corrupted dump file
        if [ $i -ne $RETRIES ]; then
            echo "Waiting $DELAY seconds before next attempt..."
            sleep $DELAY
            DELAY=$((DELAY * 2)) # Double the delay for next attempt
        else
            echo "Failed all attempts, exiting."
            exit 1
        fi
    fi
done

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
