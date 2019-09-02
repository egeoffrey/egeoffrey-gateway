#!/bin/sh

# if the config directory is empty copy there the default configuration
if [ ! "$(ls -A /gateway/config)" ]; then
    echo -e "Deploying default configuration..."
    cp -Rf /gateway/default-config/* /gateway/config
fi

# copy test CA certificate in /etc/ssl/certs
ln -s /gateway/default-config/certs/ca.crt /etc/ssl/certs/eGeoffrey_test_CA.pem

# rehash certificates in case a custom certificate has been mapped into /etc/ssl/certs
for file in /etc/ssl/certs/*.pem; do ln -s "$file" "$(openssl x509 -hash -noout -in "$file")".0; done

# execute configured command
echo $@
exec "$@"