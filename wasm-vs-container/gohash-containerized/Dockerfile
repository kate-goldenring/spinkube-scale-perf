# Use the official golang image as the base image
FROM golang:latest AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Go modules and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the source code into the container
COPY *.go ./

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o /gohash

# # Stage 3: Final stage to run the application
# FROM scratch

# # Copy the built executable from the previous stage
# COPY --from=build /gohash /

# Expose port 8080 to the outside world
EXPOSE 3000

# Command to run the executable
CMD ["/gohash"]
