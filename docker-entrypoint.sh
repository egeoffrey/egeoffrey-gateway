#!/bin/sh

# execute mosquitto
if [ "$1" = 'mosquitto' ]; then
    # if the config directory is empty copy there the default configuration
    if [ ! "$(ls -A config)" ]; then
        echo -e "Deploying default configuration..."
        cp -Rf default_config/* config
    fi
    # copy test CA certificate in /etc/ssl/certs
    cp -f default_config/certs/ca.crt /etc/ssl/certs/eGeoffrey_test_CA.pem

    # rehash certificates in case a custom certificate has been mapped into /etc/ssl/certs
    for file in /etc/ssl/certs/*.pem; do FILE=/etc/ssl/certs/"$(openssl x509 -hash -noout -in "$file")".0 &&  rm -f $FILE && ln -s "$file" $FILE; done
    # run user setup script if found
    if [ -f "./docker-init.sh" ]; then 
        echo -e "Running init script..."
        ./docker-init.sh
    fi
    # start mosquitto
    echo -e "Starting moquitto..."
    exec /usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf 
fi

# execute configured command
exec "$@"
