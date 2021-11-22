
# --- buider stage

# Base image
FROM golang:1.17.3-buster@sha256:be7aa81b44dc85ddf4008bc5f3d5a5acfca8517620d0c4a393601c8e0495fb05 AS builder

# Prepare Golang environment
ENV GO111MODULE on
ENV CGO_ENABLED 0
ENV GOOS linux

# Set working directory
WORKDIR /src

# Copy go-modules definition for the application
COPY go.mod go.mod

# Download required go-modules
RUN go mod download

# Copy application code
COPY . .

# Compile application
RUN go build -a -installsuffix cgo -o /bin/app .


# --- final stage

# Base image
FROM alpine:3.14.3@sha256:5e604d3358ab7b6b734402ce2e19ddd822a354dc14843f34d36c603521dbb4f9

# Set working directory
WORKDIR /bin

# Copy application executable
COPY --from=builder --chown=1001 /bin/app .

# Set non-root user
USER 1001

# Run application
ENTRYPOINT "/bin/app"
