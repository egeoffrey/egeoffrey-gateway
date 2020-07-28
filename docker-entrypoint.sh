#!/bin/sh

CONFIG_DIRECTORY="/mosquitto/config"
CONFIG_FILE="/mosquitto/config/mosquitto.conf"
PASSWORD_FILE="/mosquitto/config/passwords.txt"
ACL_FILE="/mosquitto/config/acl.txt"

# execute mosquitto
if [ "$1" = 'mosquitto' ]; then
	
	# check if the config directory has been mounted
	mount | grep $CONFIG_DIRECTORY
	
	# if not mounted from the host, configure the gateway
	if [ "$?" = 1 ]; then 
		# copy the default configuration
		echo -e "Copying default configuration..."
		cp -Rf default_config/* /mosquitto/config
		echo "" >> $CONFIG_FILE
		
		# add broker users provided by the env variable (in the format user1:password1\nuser2:password2)
		if [ -n "$EGEOFFREY_GATEWAY_USERS" ]; then 
			echo -e "Configuring users..."
			echo -e $EGEOFFREY_GATEWAY_USERS > $PASSWORD_FILE
			mosquitto_passwd -U $PASSWORD_FILE
			echo "allow_anonymous false" >> $CONFIG_FILE
			echo "password_file "$PASSWORD_FILE >> $CONFIG_FILE
			echo "" >> $CONFIG_FILE
		fi
		
		# enable ACLs
		if [ -n "$EGEOFFREY_GATEWAY_ACL" ]; then 
			echo -e "Enabling ACLs..."
			echo "acl_file "$ACL_FILE >> $CONFIG_FILE
			echo "" >> $CONFIG_FILE
		fi
		
		# configure remote gateway
		if [ -n "$REMOTE_EGEOFFREY_GATEWAY_HOSTNAME" ]; then
			echo -e "Configuring remote gateway..."
			echo "connection egeoffrey-gateway" >> $CONFIG_FILE
			echo "address "$REMOTE_EGEOFFREY_GATEWAY_HOSTNAME":"$REMOTE_EGEOFFREY_GATEWAY_PORT >> $CONFIG_FILE
			echo "remote_clientid egeoffrey-"$REMOTE_EGEOFFREY_ID"-system-bridge" >> $CONFIG_FILE
			echo "remote_username "$REMOTE_EGEOFFREY_ID >> $CONFIG_FILE
			if [ -n "$REMOTE_EGEOFFREY_PASSCODE" ]; then
				echo "remote_password "$REMOTE_EGEOFFREY_PASSCODE >> $CONFIG_FILE
			fi
			if [ "$REMOTE_EGEOFFREY_GATEWAY_SSL" = "1" ]; then
				echo "bridge_capath /etc/ssl/certs" >> $CONFIG_FILE
			fi
			echo "local_username "$EGEOFFREY_ID >> $CONFIG_FILE
			if [ -n "$EGEOFFREY_PASSCODE" ]; then
				echo "local_password "$EGEOFFREY_PASSCODE >> $CONFIG_FILE
			fi
			echo "bridge_insecure true" >> $CONFIG_FILE
			echo "cleansession false" >> $CONFIG_FILE
			echo "try_private true" >> $CONFIG_FILE
			echo "topic egeoffrey/+/"$REMOTE_EGEOFFREY_ID"/# out 2" >> $CONFIG_FILE
			echo "topic egeoffrey/+/"$REMOTE_EGEOFFREY_ID"/# in 0" >> $CONFIG_FILE
			echo "notifications_local_only true" >> $CONFIG_FILE
			echo "bridge_protocol_version mqttv311" >> $CONFIG_FILE
			echo "" >> $CONFIG_FILE
		fi
	fi
	
    # run user setup script if found
    if [ -f "./docker-init.sh" ]; then 
        echo -e "Running init script..."
        ./docker-init.sh
    fi
    # start mosquitto
    echo -e "Starting moquitto..."
	chown -R mosquitto.mosquitto /mosquitto
    exec /usr/sbin/mosquitto -c $CONFIG_FILE
fi

# execute configured command
exec "$@"
