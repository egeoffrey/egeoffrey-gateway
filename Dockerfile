ARG ARCHITECTURE
FROM $ARCHITECTURE/eclipse-mosquitto
COPY docker/config /mosquitto/config
EXPOSE 1883 443
