# Use the official Go image
FROM golang:alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the Go source file
COPY main.go .

# Expose port 8080
EXPOSE 3000

# Run the application
CMD ["go", "run", "main.go"]
