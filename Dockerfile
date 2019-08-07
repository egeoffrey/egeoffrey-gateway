### EGEOFFREY ###

### define base image
ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto

### copy files into the image
COPY docker/config /mosquitto/config
COPY docker/docker-entrypoint.sh /docker-entrypoint.sh

### expose ports
EXPOSE 1883 443
