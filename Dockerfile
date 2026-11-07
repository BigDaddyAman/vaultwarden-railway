
FROM vaultwarden/server:latest

ENV ROCKET_ADDRESS=0.0.0.0 \
    ROCKET_PORT=8080 \
    ROCKET_PROFILE=release \
    DATA_FOLDER=/data

EXPOSE 8080
