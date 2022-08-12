# To be sure we've SSL enabled by default we will create a self-signed
# certificate as fallback. This will allow us to enable nginx or any
# webserver.

# Default
SSL_HOME='/opt/local/etc/nginx/ssl/'

# Create folder if it doesn't exists
mkdir -p "${SSL_HOME}"
chmod 0700 /opt/local/etc/nginx/ssl


# Self-signed certificate generator
/opt/qutic/bin/ssl-selfsigned.sh -d ${SSL_HOME} -f nginx
