# Configuración HTTP (redirección a HTTPS)
<VirtualHost *:80>
    ServerName {{VIRTUAL_HOST_NAME}}
    Redirect permanent / https://{{VIRTUAL_HOST_NAME}}
</VirtualHost>

# Virtual host para {{VIRTUAL_HOST_NAME}}
<VirtualHost *:80>
    ServerName {{VIRTUAL_HOST_NAME}}
    ServerAlias *.{{VIRTUAL_HOST_NAME}}
    ServerAdmin webmaster@shoropio.com
    DocumentRoot "{{WEB_SERVER_DIR}}/www"

    <Directory "{{WEB_SERVER_DIR}}/www">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "{{LOGS_DIR}}/{{VIRTUAL_HOST_NAME}}-error.log"
    CustomLog "{{LOGS_DIR}}/{{VIRTUAL_HOST_NAME}}-access.log" combined
</VirtualHost>

# Configuración HTTPS para {{VIRTUAL_HOST_NAME}}
<VirtualHost *:443>
    ServerName {{VIRTUAL_HOST_NAME}}
    ServerAlias *.{{VIRTUAL_HOST_NAME}}
    ServerAdmin webmaster@shoropio.com
    DocumentRoot "{{WEB_SERVER_DIR}}/www"

    <Directory "{{WEB_SERVER_DIR}}/www">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "{{LOGS_DIR}}/{{VIRTUAL_HOST_NAME}}-error.log"
    CustomLog "{{LOGS_DIR}}/{{VIRTUAL_HOST_NAME}}-access.log" combined

    SSLEngine on
    SSLCertificateFile {{SSL_DIR}}/{{VIRTUAL_HOST_NAME}}.crt
    SSLCertificateKeyFile {{SSL_DIR}}/{{VIRTUAL_HOST_NAME}}.key
</VirtualHost>
