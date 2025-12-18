# MongoDB Backup Kubernetes CronJob

This repository contains a Dockerfile and script to perform a daily MongoDB dump and upload the result to an S3 or MinIO storage endpoint. It is designed to run as a Kubernetes CronJob using the image `thegalah/k8s-mongodump-s3:1.1.0`.

## Features

- Perform a daily mongodump from a given MongoDB connection string
- Customize the dump with various options, including a configurable file prefix
- Upload the dump to either an S3 or MinIO endpoint with optional no-sign request
- Support for TLS/SSL connections with custom CA certificates
- Configurable via environment variables
- Automatic retry with exponential backoff on failure
- Suitable for running as a Kubernetes CronJob

## Usage

### Building the Docker Image

If you want to build the image yourself:

```bash
docker build -t thegalah/k8s-mongodump-s3:1.1.0 .
```

### Running with Docker

```bash
docker run -e MONGO_CONNECTION_STRING=your_connection_string -e S3_OR_MINIO_ENDPOINT=your_s3_or_minio_endpoint -e STORAGE_PATH=your_storage_path thegalah/k8s-mongodump-s3:1.1.0
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `MONGO_CONNECTION_STRING` | Yes | The connection string for the MongoDB instance |
| `S3_OR_MINIO_ENDPOINT` | Yes | The endpoint for the MinIO or S3 storage |
| `STORAGE_PATH` | Yes | The path where the dump should be stored |
| `DUMP_PREFIX` | No | The prefix for the dump files (defaults to "dump") |
| `ACCESS_KEY` | No | Access key for S3 or MinIO |
| `SECRET_KEY` | No | Secret key for S3 or MinIO |
| `MONGODUMP_EXTRA_ARGS` | No | Additional arguments to pass to mongodump (e.g., `--tlsCAFile=/path/to/ca.crt`) |

## Running as a Kubernetes CronJob

You can create a Kubernetes CronJob to run this Docker image daily within a Kubernetes cluster.

### Basic Example

```yaml
apiVersion: batch/v1
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
              image: thegalah/k8s-mongodump-s3:1.1.0
              env:
                - name: MONGO_CONNECTION_STRING
                  value: your_connection_string
                - name: S3_OR_MINIO_ENDPOINT
                  value: your_s3_or_minio_endpoint
                - name: STORAGE_PATH
                  value: your_storage_path
                - name: DUMP_PREFIX
                  value: your_prefix
                - name: ACCESS_KEY
                  value: your_access_key
                - name: SECRET_KEY
                  value: your_secret_key
          restartPolicy: Never
```

### TLS/SSL Example

For MongoDB instances with TLS enabled using a custom CA certificate:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mongodb-backup-cronjob
spec:
  schedule: "0 0 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: mongodb-backup
              image: thegalah/k8s-mongodump-s3:1.1.0
              env:
                - name: MONGO_CONNECTION_STRING
                  valueFrom:
                    secretKeyRef:
                      name: mongodb-connection-secret
                      key: connectionString.standard
                - name: S3_OR_MINIO_ENDPOINT
                  value: http://minio.example.com:9000
                - name: STORAGE_PATH
                  value: mongodumps
                - name: DUMP_PREFIX
                  value: myapp_prod
                - name: ACCESS_KEY
                  value: minio-access-key
                - name: SECRET_KEY
                  value: minio-secret-key
                - name: MONGODUMP_EXTRA_ARGS
                  value: "--tlsCAFile=/etc/ssl/mongodb/ca.crt"
              volumeMounts:
                - name: mongodb-ca
                  mountPath: /etc/ssl/mongodb
                  readOnly: true
          volumes:
            - name: mongodb-ca
              secret:
                secretName: mongodb-ca-secret
          restartPolicy: Never
```

Apply this YAML file using `kubectl apply -f filename.yaml`.

## Retry Behavior

The script automatically retries failed mongodump operations up to 7 times with exponential backoff:
- Attempt 1: immediate
- Attempt 2: wait 1 second
- Attempt 3: wait 2 seconds
- Attempt 4: wait 4 seconds
- Attempt 5: wait 8 seconds
- Attempt 6: wait 16 seconds
- Attempt 7: wait 32 seconds

## License

MIT License

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!
