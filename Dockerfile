### EGEOFFREY ###

### define base image
ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto

### expose the data folder into a static location
RUN mkdir -p /gateway && ln -s /mosquitto/config /gateway/config && ln -s /mosquitto/data /gateway/data && ln -s /mosquitto/log /gateway/logs && rm -f /gateway/config/mosquitto.conf
VOLUME ["/gateway/config", "/gateway/data", "/gateway/logs"]

### copy in the default config
COPY docker/config /gateway/default-config
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

### expose ports
EXPOSE 1883 443
