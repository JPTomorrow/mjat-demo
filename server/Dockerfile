# Use an official lightweight Linux image.
FROM ubuntu:22.04

# Set the working directory inside the container.
WORKDIR /app

# Copy the exported Godot dedicated server binary into the container.
# Ensure that the binary is located in the same directory as this Dockerfile.
COPY ./game-server-files/* .

# Grant execute permissions to the binary.
RUN chmod +x ./*

# Expose port 8081 so that the server can receive messages.
EXPOSE 80

# Set the default command to run the Godot dedicated server.
CMD ["./mjat-demo-server.sh", "-s"]
