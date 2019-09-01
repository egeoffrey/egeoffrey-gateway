#!/bin/sh

# if the config directory is empty copy there the default configuration
if [ ! "$(ls -A /gateway/config)" ]; then
    echo -e "Deploying default configuration..."
    cp -Rf /gateway/default-config/* /gateway/config
fi

# execute configured command
echo $@
exec "$@"