# MongoDB Backup Kubernetes Job

This repository contains a Dockerfile and script to perform a MongoDB dump and upload the result to an S3 or MinIO storage endpoint. It is designed to run as a Kubernetes job.

## Features

- Perform a mongodump from a given MongoDB connection string
- Upload the dump to either an S3 or MinIO endpoint
- Configurable via environment variables
- Suitable for running as a Kubernetes job

## Usage

### Building the Docker Image

\`\`\`bash
docker build -t your-image-name .
\`\`\`

### Running with Docker

\`\`\`bash
docker run -e MONGO_CONNECTION_STRING=your_connection_string -e MINIO_ENDPOINT=your_minio_endpoint -e STORAGE_PATH=your_storage_path your-image-name
\`\`\`

### Environment Variables

- `MONGO_CONNECTION_STRING`: The connection string for the MongoDB instance
- `MINIO_ENDPOINT` or `S3_ENDPOINT`: The endpoint for the MinIO or S3 storage
- `STORAGE_PATH`: The path where the dump should be stored

## Running as a Kubernetes Job

You can create a Kubernetes job YAML file to run this Docker image as a job within a Kubernetes cluster. Make sure to specify the environment variables as needed.

## License

MIT https://opensource.org/license/mit/

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!
