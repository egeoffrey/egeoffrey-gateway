#!/bin/sh

CONFIG_FILE="/mosquitto/config/mosquitto.conf"
PASSWORD_FILE="/mosquitto/config/passwords.txt"

# execute mosquitto
if [ "$1" = 'mosquitto' ]; then
    # if the config directory is empty copy there the default configuration
    if [ ! "$(ls -A /mosquitto/config)" ]; then
        echo -e "Deploying default configuration..."
        cp -Rf default_config/* /mosquitto/config
    fi
    
    # add broker users provided by the env variable (in the format user1:password1\nuser2:password2)
    if [ -n "$EGEOFFREY_GATEWAY_USERS" ]; then 
        echo -e "Configuring users..."
        echo -e $EGEOFFREY_GATEWAY_USERS > $PASSWORD_FILE
        mosquitto_passwd -U $PASSWORD_FILE
        sed -i -E "s/^#password_file (.+)$/password_file \1/" $CONFIG_FILE
        sed -i -E "s/^#allow_anonymous (.+)$/allow_anonymous false/" $CONFIG_FILE
    else
        echo "" > $PASSWORD_FILE
        sed -i -E "s/^password_file (.+)$/#password_file \1/" $CONFIG_FILE
        sed -i -E "s/^allow_anonymous (.+)$/#allow_anonymous false/" $CONFIG_FILE
    fi
    
    # enable ACLs
    if [ -n "$EGEOFFREY_GATEWAY_ACL" ]; then 
        echo -e "Enabling ACLs..."
        sed -i -E "s/^#acl_file (.+)/acl_file \1/" $CONFIG_FILE
    else
        sed -i -E "s/^acl_file (.+)/#acl_file \1/" $CONFIG_FILE
    fi

    # run user setup script if found
    if [ -f "./docker-init.sh" ]; then 
        echo -e "Running init script..."
        ./docker-init.sh
    fi
    # start mosquitto
    echo -e "Starting moquitto..."
    exec /usr/sbin/mosquitto -c $CONFIG_FILE
fi

# execute configured command
exec "$@"
