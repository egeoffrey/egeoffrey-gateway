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

### setup the image
RUN ln -s /mosquitto/config config \
  && ln -s /mosquitto/data data \
  && ln -s /mosquitto/log logs \
  && rm -f /gateway/config/mosquitto.conf \
  && chown -R mosquitto.mosquitto /gateway \
  && chown -R mosquitto.mosquitto /mosquitto \
  && cp -f default_config/certs/ca.crt /etc/ssl/certs/eGeoffrey_test_CA.pem \
  && for file in /etc/ssl/certs/*.pem; do FILE=/etc/ssl/certs/"$(openssl x509 -hash -noout -in "$file")".0 &&  rm -f $FILE && ln -s "$file" $FILE; done

### expose volumes
VOLUME ["/gateway/config", "/gateway/data", "/gateway/logs"]

### set entrypoint
ENTRYPOINT ["sh", "docker-entrypoint.sh"]
CMD ["mosquitto"]
