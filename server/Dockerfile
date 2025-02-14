FROM ubuntu:22.04

WORKDIR /app
COPY ./game-server-files/* .
RUN chmod +x ./*
EXPOSE 80

CMD ["./mjat-demo-server.sh", "-s"]
