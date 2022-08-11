#!/bin/bash

#################################
# nginx config
#
if mdata-get mail_adminaddr 1>/dev/null 2>&1; then
  # Configure PHP sendmail return-path if possible
  echo "php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f $(mdata-get mail_adminaddr)" \
    >> /opt/local/etc/php-fpm.d/www.conf
fi

sed -i \
    "s:nc.example.com:$(mdata-get server_name):g" \
    /opt/local/etc/nginx/nginx.conf

# Enable PHP-FPM
chmod 0700 /opt/local/etc/nginx/ssl
/usr/sbin/svcadm enable svc:/pkgsrc/php-fpm:default
/usr/sbin/svcadm enable nginx
