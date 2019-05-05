FROM eclipse-mosquitto
COPY config /mosquitto/config
EXPOSE 1883 443
