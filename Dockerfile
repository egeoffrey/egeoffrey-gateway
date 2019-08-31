### EGEOFFREY ###

### define base image
ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto

### copy in the default config
COPY docker/config /mosquitto/config

### expose the data folder into a static location
RUN mkdir -p /gateway && ln -s /mosquitto/config /gateway/config && ln -s /mosquitto/data /gateway/data && ln -s /mosquitto/log /gateway/logs 
VOLUME ["/gateway/config", "/gateway/data", "/gateway/logs"]

### expose ports
EXPOSE 1883 443
