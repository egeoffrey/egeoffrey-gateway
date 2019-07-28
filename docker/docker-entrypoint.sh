#!/bin/sh

CONFIG_MOUNT="/config"
MQTT_CONFIG="/mosquitto/config"

# create the config directory
mkdir -p $CONFIG_MOUNT
# if the directory is empty copy there the default configuration
if [ ! "$(ls -A $CONFIG_MOUNT)" ]; then
    echo -e "Copying default configuration into $CONFIG_MOUNT..."
    cp -Rf $MQTT_CONFIG/* $CONFIG_MOUNT
fi
# make a symbolic link so to use the user's configuration
rm -rf $MQTT_CONFIG
ln -s $CONFIG_MOUNT $MQTT_CONFIG


# execute configured command
exec "$@"
