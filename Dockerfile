### EGEOFFREY ###

### define base image
ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto

### install dependencies
RUN apk update && apk add ca-certificates openssl && rm -rf /var/cache/apk/*

### expose the data folder into a static location
RUN mkdir -p /gateway && ln -s /mosquitto/config /gateway/config && ln -s /mosquitto/data /gateway/data && ln -s /mosquitto/log /gateway/logs && rm -f /gateway/config/mosquitto.conf && chown -R mosquitto.mosquitto /gateway
VOLUME ["/gateway/config", "/gateway/data", "/gateway/logs"]

### copy in the default config
COPY docker/config /gateway/default-config
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

### expose ports
EXPOSE 443 1883 8883
