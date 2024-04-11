FROM alpine:latest AS builder

# Install curl
RUN apk --no-cache add curl

# Install Spin 2.3.1
RUN curl -LRO https://github.com/fermyon/spin/releases/download/v2.3.1/spin-v2.3.1-static-linux-amd64.tar.gz && \
    tar -xvf spin-v2.3.1-static-linux-amd64.tar.gz

# Second stage: Final stage
FROM alpine:latest

# Copy Spin binary from the builder stage
COPY --from=builder /spin /usr/local/bin/spin

# Set the working directory
WORKDIR /app

# Copy the Spin configuration file
COPY spin.toml spin.toml

# Copy the compiled WASM file
COPY target/wasm32-wasi/release/hello.wasm target/wasm32-wasi/release/hello.wasm

# Expose port
EXPOSE 3000

# Run the Spin command to spin up the application
CMD ["spin", "up", "--listen", "0.0.0.0:3000"]
