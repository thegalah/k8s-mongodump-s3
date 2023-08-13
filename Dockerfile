FROM mongo:6.0.4

# Install AWS CLI
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --upgrade pip && \
    pip3 install awscli

# Copy the script
COPY mongodump.sh /mongodump.sh
RUN chmod +x /mongodump.sh

# Command to run the script
ENTRYPOINT ["/mongodump.sh"]
