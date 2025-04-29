# Virtual host para phpMyAdmin
<VirtualHost *:80>
    ServerName phpmyadmin.{{VIRTUAL_HOST_NAME}}
    ServerAlias *.{{VIRTUAL_HOST_NAME}}
    ServerAdmin webmaster@shoropio.com
    DocumentRoot "{{WEB_SERVER_DIR}}/etc/apps/phpmyadmin"

    <Directory "{{WEB_SERVER_DIR}}/etc/apps/phpmyadmin">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "{{LOGS_DIR}}/phpmyadmin-{{VIRTUAL_HOST_NAME}}-error.log"
    CustomLog "{{LOGS_DIR}}/phpmyadmin-{{VIRTUAL_HOST_NAME}}-access.log" combined
</VirtualHost>

<VirtualHost *:443>
    ServerName phpmyadmin.{{VIRTUAL_HOST_NAME}}
    ServerAlias *.{{VIRTUAL_HOST_NAME}}
    ServerAdmin webmaster@shoropio.com
    DocumentRoot "{{WEB_SERVER_DIR}}/etc/apps/phpmyadmin"

    <Directory "{{WEB_SERVER_DIR}}/etc/apps/phpmyadmin">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "{{LOGS_DIR}}/phpmyadmin-{{VIRTUAL_HOST_NAME}}-error.log"
    CustomLog "{{LOGS_DIR}}/phpmyadmin-{{VIRTUAL_HOST_NAME}}-access.log" combined

    SSLEngine on
    SSLCertificateFile {{SSL_DIR}}/{{VIRTUAL_HOST_NAME}}.crt
    SSLCertificateKeyFile {{SSL_DIR}}/{{VIRTUAL_HOST_NAME}}.key
</VirtualHost>
