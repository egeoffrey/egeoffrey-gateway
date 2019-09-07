### EGEOFFREY ###

### define base image
ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto:1.5.8

### define workdir
ENV WORKDIR=/gateway
WORKDIR $WORKDIR

### install dependencies
RUN apk update && apk add ca-certificates openssl && rm -rf /var/cache/apk/*

### expose ports
EXPOSE 443 1883 8883

### copy in the files
COPY . $WORKDIR

### expose the data folder into a static location
RUN ln -s /mosquitto/config config \
  && ln -s /mosquitto/data data \
  && ln -s /mosquitto/log logs \
  && rm -f /gateway/config/mosquitto.conf \
  && chown -R mosquitto.mosquitto /gateway
VOLUME ["/gateway/config", "/gateway/data", "/gateway/logs"]

ENTRYPOINT ["sh", "docker-entrypoint.sh"]
CMD ["mosquitto"]
