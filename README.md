# MongoDB Backup Kubernetes CronJob

This repository contains a Dockerfile and script to perform a daily MongoDB dump and upload the result to an S3 or MinIO storage endpoint. It is designed to run as a Kubernetes CronJob using the image `thegalah/k8s-mongodump-s3:1.0.0`.

## Features

- Perform a daily mongodump from a given MongoDB connection string
- Customize the dump with various options, including a configurable file prefix
- Upload the dump to either an S3 or MinIO endpoint with optional no-sign request
- Configurable via environment variables
- Suitable for running as a Kubernetes CronJob

## Usage

### Building the Docker Image

If you want to build the image yourself:

```bash
docker build -t thegalah/k8s-mongodump-s3:1.0.0 .
```

### Running with Docker

```bash
docker run -e MONGO_CONNECTION_STRING=your_connection_string -e S3_OR_MINIO_ENDPOINT=your_s3_or_minio_endpoint -e STORAGE_PATH=your_storage_path thegalah/k8s-mongodump-s3:1.0.0
```

### Environment Variables

- `MONGO_CONNECTION_STRING`: The connection string for the MongoDB instance
- `S3_OR_MINIO_ENDPOINT`: The endpoint for the MinIO or S3 storage
- `STORAGE_PATH`: The path where the dump should be stored
- `DUMP_PREFIX`: The prefix for the dump files (Optional, defaults to "dump")
- `MONGO_USERNAME`: MongoDB username (Optional)
- `MONGO_PASSWORD`: MongoDB password (Optional)
- `MONGO_DATABASE`: Name of the database to dump (Optional)
- `MONGO_COLLECTION`: Name of the collection to dump (Optional)
- `MONGO_QUERY`: Query filter in JSON format (Optional)
- `ACCESS_KEY`: Access key for S3 or MinIO (Optional)
- `SECRET_KEY`: Secret key for S3 or MinIO (Optional)

## Running as a Kubernetes CronJob

You can create a Kubernetes CronJob to run this Docker image daily within a Kubernetes cluster. Here's an example YAML file:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: mongodb-backup-cronjob
spec:
  schedule: "0 0 * * *" # Runs daily at midnight
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: mongodb-backup
              image: thegalah/k8s-mongodump-s3:1.0.0
              env:
                - name: MONGO_CONNECTION_STRING
                  value: your_connection_string
                - name: S3_OR_MINIO_ENDPOINT
                  value: your_s3_or_minio_endpoint
                - name: STORAGE_PATH
                  value: your_storage_path
                - name: DUMP_PREFIX
                  value: your_prefix # Optional
                - name: MONGO_USERNAME
                  value: your_username # Optional
                - name: MONGO_PASSWORD
                  valueFrom: # Optional
                    secretKeyRef:
                      name: mongodb-password-secret
                      key: password
                - name: MONGO_DATABASE
                  value: your_database # Optional
                - name: MONGO_COLLECTION
                  value: your_collection # Optional
                - name: MONGO_QUERY
                  value: your_query # Optional
                - name: ACCESS_KEY
                  value: your_access_key # Optional
                - name: SECRET_KEY
                  value: your_secret_key # Optional
          restartPolicy: OnFailure
```

Apply this YAML file using `kubectl apply -f filename.yaml`.

## License

MIT License

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!
