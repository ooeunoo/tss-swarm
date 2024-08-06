FROM golang:1.22.4

WORKDIR /app

# Copy go mod file
COPY go.mod ./

# Copy go sum file if it exists
COPY go.sum* ./

# Download all dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the application
RUN go build -o gateway

# Run the application
CMD ["./gateway"]
