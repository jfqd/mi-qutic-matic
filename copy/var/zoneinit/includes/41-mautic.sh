#!/bin/bash

echo "Setup local config"
if mdata-get mysql_host 1>/dev/null 2>&1; then
  MYSQL_HOST=`mdata-get mysql_host`
else
  MYSQL_HOST=127.0.0.1
fi
if mdata-get mysql_db 1>/dev/null 2>&1; then
  MYSQL_DB=`mdata-get mysql_db`
else
  MYSQL_DB=mautic
fi
if mdata-get mysql_user 1>/dev/null 2>&1; then
  MYSQL_USER=`mdata-get mysql_user`
else
  MYSQL_USER=mautic
fi
if mdata-get mysql_password 1>/dev/null 2>&1; then
  MYSQL_PWD=`mdata-get mysql_password`
else
  MYSQL_PWD=$(LC_ALL=C tr -cd '[:alnum:]!%=+_' < /dev/urandom | head -c24)
fi
if mdata-get site_url 1>/dev/null 2>&1; then
  SITE_URL=`mdata-get site_url`
else
  SITE_URL=$(/usr/bin/hostname)
fi
SECRET_KEY=$(LC_ALL=C tr -cd '[:alnum:]!%=+_' < /dev/urandom | head -c24 | shasum -a 256 | awk '{ print $1 }')

# TODO: customize other settings
FROM_NAME=""
FROM_EMAIL=""
MAIL_HOST=""
MAIL_PORT=""
MAIL_USR=""
MAIL_PWD=""

cp /var/www/htdocs/mautic/current/app/config/local.php \
  /var/www/htdocs/mautic/current/app/config/local.php.bak || true

cat > /var/www/htdocs/mautic/current/app/config/local.php << EOF
<?php
$parameters = array(
        'db_driver' => 'pdo_mysql',
        'db_host' => '${MYSQL_HOST}',
        'db_table_prefix' => null,
        'db_port' => '3306',
        'db_name' => '${MYSQL_DB}',
        'db_user' => '${MYSQL_USER}',
        'db_password' => '${MYSQL_PWD}',
        'db_backup_tables' => 0,
        'db_backup_prefix' => 'bak_',
        'mailer_from_name' => '${FROM_NAME}',
        'mailer_from_email' => '${FROM_EMAIL}',
        'mailer_transport' => 'smtp',
        'mailer_host' => '${MAIL_HOST}',
        'mailer_port' => '${MAIL_PORT}',
        'mailer_user' => '${MAIL_USR}',
        'mailer_password' => '${MAIL_PWD}',
        'mailer_amazon_region' => '',
        'mailer_amazon_other_region' => null,
        'mailer_api_key' => null,
        'mailer_encryption' => 'tls',
        'mailer_auth_mode' => 'plain',
        'mailer_spool_type' => 'file',
        'mailer_spool_path' => '%kernel.root_dir%/../var/spool',
        'secret_key' => '${SECRET_KEY}',
        'site_url' => '${SITE_URL}',
);
EOF

echo "Fix Gravatar usage"
sed -i \
    -e "s#'https://www.gravatar.com/avatar/'.*;#'https://download.qutic.com/default_avatar.jpg';#" \
    -e "s#return \$url.*;#return \$url;#" \
    /var/www/htdocs/mautic/current/app/bundles/CoreBundle/Templating/Helper/GravatarHelper.php

# TODO: Fix Google Fonts usage
# echo "Fix Google Fonts usage"

echo "Setup crontab"
cat >> /var/spool/cron/crontabs/www << EOF
# mautic cronjobx
0,15,30,45 * * * * /opt/local/bin/php /var/www/htdocs/mautic/current/bin/console mautic:segments:update
5,20,35,50 * * * * /opt/local/bin/php /var/www/htdocs/mautic/current/bin/console mautic:campaigns:update
10,25,40,55 * * * * /opt/local/bin/php /var/www/htdocs/mautic/current/bin/console mautic:campaigns:trigger
2,17,32,47 * * * * /opt/local/bin/php /var/www/htdocs/mautic/current/bin/console mautic:emails:send
# end
EOF
chmod 0600 /var/spool/cron/crontabs/www