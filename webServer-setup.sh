#!/bin/bash

#############################################################
# Script: web-dev-setup.sh
# Descripción: Script completo para configurar un entorno de
# desarrollo web en Windows (Git Bash) o WSL (Ubuntu).
# Soporta instalación de Apache/Nginx, PHP, MariaDB/MySQL,
# Node.js, Python, Composer, phpMyAdmin, extensiones útiles,
# Virtual Hosts con SSL, backups, logs y más.
#
# Autor: Tú
# Fecha de documentación: 2025-04-20
# Uso: Ejecutar en consola bash: ./web-dev-setup.sh
# Requisitos: conexión a internet
# Compatible con: Git Bash (Windows 10+)
#############################################################

# Variables de configuración
WEB_SERVER_DIR="C:/webServer"

# Rutas base
DOWNLOADS_DIR="$WEB_SERVER_DIR/downloads"
BIN_DIR="$WEB_SERVER_DIR/bin"
TEMP_DIR="$WEB_SERVER_DIR/tmp"
ETC_DIR="$WEB_SERVER_DIR/etc"
SSL_DIR="$WEB_SERVER_DIR/etc/ssl"
APPS_DIR="$WEB_SERVER_DIR/etc/apps"
LOGS_DIR="$WEB_SERVER_DIR/logs"

# Variables de versión por defecto
DEFAULT_PHP_VERSION="8.3.20"
DEFAULT_PYTHON_VERSION="3.13.3"
DEFAULT_NODE_VERSION="22.15.0"

# DB Engine
DEFAULT_DB_ENGINE="MariaDB" # or MySQL
DEFAULT_DB_VERSION="11.4.5" # or MySQL 8.0.42

# phpMyAdmin
DEFAULT_PHPMYADMIN_VERSION="5.2.2"

# Server Engine
DEFAULT_WEB_SERVER_ENGINE="Apache"
DEFAULT_WEB_SERVER_ENGINE_VERSION="2.4.63"
DEFAULT_APACHE_VERSION="2.4.63"
DEFAULT_NGINX_VERSION="1.26.3" # 1.27.5
DEFAULT_COMPOSER_VERSION="2.8.8"
DEFAULT_GIT_VERSION="2.49.0"

# Variables adicionales
VIRTUAL_HOST_NAME="webserver.local"
SSL_ENABLED=true

# Colores para la salida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detectar el usuario de Windows
USERNAME="${USERNAME:-$(whoami)}"
USER_HOME_DIR="$USERNAME"

#USERNAME="Shoropio"
#USERPROFILE="C:\\Users\\Shoropio"

# Generar .env si no existe
generate_default_env() {
    # Asegurar que el directorio base exista antes de crear el .env
    if [ ! -d "$WEB_SERVER_DIR" ]; then
        mkdir -p "$WEB_SERVER_DIR"
    fi

    cat > "$WEB_SERVER_DIR/webServer.env" <<EOF
# DB Engine
INSTALLED_DB_ENGINE=$DEFAULT_DB_ENGINE
INSTALLED_DB_ENGINE_VERSION=$DEFAULT_DB_VERSION
INSTALLED_DB_ENGINE_DIR=""

# PHP
INSTALLED_PHP_VERSION=$DEFAULT_PHP_VERSION
INSTALLED_PHP_DIR=""

# NodeJs
INSTALLED_NODE_VERSION=$DEFAULT_NODE_VERSION

# Nginx
INSTALLED_NGINX_VERSION=$DEFAULT_NGINX_VERSION
INSTALLED_NGINX_DIR=""

# Server Engine
INSTALLED_WEB_SERVER_ENGINE=$DEFAULT_WEB_SERVER_ENGINE
INSTALLED_WEB_SERVER_ENGINE_VERSION=$DEFAULT_WEB_SERVER_ENGINE_VERSION
INSTALLED_WEB_SERVER_ENGINE_DIR=""
EOF
    echo -e "${GREEN}Archivo webServer.env generado con valores por defecto.${NC}"
}

# Llamar load_env()
load_env() {
    if [ ! -f "$WEB_SERVER_DIR/webServer.env" ]; then
        echo -e "${YELLOW}Archivo webServer.env no encontrado. Creando con valores por defecto...${NC}"
        generate_default_env
    fi

    export $(grep -v '^#' "$WEB_SERVER_DIR/webServer.env" | xargs)
    echo -e "${GREEN}Variables de entorno cargadas.${NC}"
}

# Actualizar o agregar variable en webServer.env
update_env_var() {
    local var_name="$1"
    local new_value="$2"
    local env_file="$WEB_SERVER_DIR/webServer.env"

    if [ ! -f "$env_file" ]; then
        echo -e "${YELLOW}Archivo $env_file no encontrado. Creándolo...${NC}"
        generate_default_env
    fi

    if grep -q "^$var_name=" "$env_file"; then
        # Si la variable existe, reemplazar su valor
        sed -i "s|^$var_name=.*|$var_name=\"$new_value\"|" "$env_file"
        echo -e "${GREEN}Variable $var_name actualizada en $env_file.${NC}"
    else
        # Si no existe, agregarla al final
        echo "$var_name=\"$new_value\"" >> "$env_file"
        echo -e "${GREEN}Variable $var_name agregada en $env_file.${NC}"
    fi
}

# Llamar al cargar
load_env

# Función para crear estructura de directorios automáticamente con .gitkeep
create_directories() {
    echo -e "${BLUE}Creando estructura de directorios...${NC}"

    # Array con directorios principales
    main_dirs=(
        "$WEB_SERVER_DIR"
        "$TEMP_DIR"
        "$ETC_DIR"
        "$ETC_DIR/apache2/alias"
        "$ETC_DIR/apache2/sites-enabled"
        "$WEB_SERVER_DIR/templates/apache"
        "$WEB_SERVER_DIR/templates/nginx"
        "$SSL_DIR"
        "$APPS_DIR"
        "$LOGS_DIR"
        "$DOWNLOADS_DIR"
        "$BIN_DIR"
        "$WEB_SERVER_DIR/www"
        "$WEB_SERVER_DIR/templates"
    )

    # Array con subdirectorios para componentes en BIN_DIR
    bin_subdirs=(
        "php"
        "apache"
        "nginx"
        "mysql"
        "mariadb"
    )

    # Crear los directorios principales si no existen
    for dir in "${main_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            touch "$dir/.gitkeep"
            echo -e "${CYAN}Creado: $dir${NC}"
        fi
    done

    # Crear subdirectorios para los componentes
    for sub in "${bin_subdirs[@]}"; do
        dir="$BIN_DIR/$sub"
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            touch "$dir/.gitkeep"
            echo -e "${CYAN}Creado: $dir${NC}"
        fi
    done

    # Crear archivos de prueba si es necesario
    create_test_files

    echo -e "${GREEN}Estructura de directorios lista en $WEB_SERVER_DIR.${NC}"
}

# Crear directorios
create_directories

# Función para mostrar resumen de instalación
show_installation_summary() {
    clear
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${GREEN}          RESUMEN DE LA INSTALACIÓN          ${NC}"
    echo -e "${GREEN}=============================================${NC}"
    echo ""
    echo -e "${BLUE}Rutas de instalación:${NC}"
    echo -e " - Directorio raíz: ${YELLOW}$WEB_SERVER_DIR${NC}"
    echo -e " - Proyectos web: ${YELLOW}$WEB_SERVER_DIR/www${NC}"
    echo -e " - Binarios: ${YELLOW}$BIN_DIR${NC}"
    echo -e " - Descargas: ${YELLOW}$DOWNLOADS_DIR${NC}"
    echo ""

    if [ -n "$INSTALLED_PHP_VERSION" ]; then
        echo -e "${BLUE}PHP:${NC}"
        echo -e " - Versión: ${YELLOW}$INSTALLED_PHP_VERSION${NC}"
        echo -e " - Ruta: ${YELLOW}$BIN_DIR/php/$INSTALLED_PHP_VERSION${NC}"
        echo ""
    fi

    if [ -n "$INSTALLED_DB_ENGINE" ]; then
        echo -e "${BLUE}Base de Datos:${NC}"
        echo -e " - Motor: ${YELLOW}$INSTALLED_DB_ENGINE${NC}"
        if [ "$INSTALLED_DB_ENGINE" = "MySQL" ]; then
            echo -e " - Ruta: ${YELLOW}$BIN_DIR/mysql/$DEFAULT_DB_VERSION${NC}"
        else
            echo -e " - Ruta: ${YELLOW}$BIN_DIR/mariadb/$DEFAULT_DB_VERSION${NC}"
        fi
        echo ""
    fi

    if [ -n "$INSTALLED_WEB_SERVER_ENGINE" ]; then
        echo -e "${BLUE}Servidor Web:${NC}"
        echo -e " - Tipo: ${YELLOW}$INSTALLED_WEB_SERVER_ENGINE${NC}"
        if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
            echo -e " - Ruta: ${YELLOW}$BIN_DIR/apache/$DEFAULT_APACHE_VERSION${NC}"
            echo -e " - Archivo de configuración: ${YELLOW}$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf${NC}"
        else
            echo -e " - Ruta: ${YELLOW}$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION${NC}"
            echo -e " - Archivo de configuración: ${YELLOW}$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf${NC}"
        fi
        echo ""
    fi

    echo -e "${BLUE}phpMyAdmin:${NC}"
    echo -e " - Ruta: ${YELLOW}$ETC/apps/phpmyadmin${NC}"
    echo -e " - URL: ${YELLOW}https://phpmyadmin.local${NC}"
    echo ""

    if [ "$SSL_ENABLED" = true ]; then
        echo -e "${GREEN}Certificado SSL configurado para $VIRTUAL_HOST_NAME${NC}"
        echo -e " - URL segura: ${YELLOW}https://$VIRTUAL_HOST_NAME${NC}"
        echo ""
    fi

    if [ -n "$VIRTUAL_HOST_NAME" ]; then
        echo -e "${GREEN}VirtualHost configurado${NC}"
        echo -e " - Nombre: ${YELLOW}$VIRTUAL_HOST_NAME${NC}"
        echo -e " - Directorio: ${YELLOW}$WEB_SERVER_DIR/www${NC}"
        echo -e " - URL: ${YELLOW}http://$VIRTUAL_HOST_NAME${NC}"
        if [ "$SSL_ENABLED" = true ]; then
            echo -e " - URL segura: ${YELLOW}https://$VIRTUAL_HOST_NAME${NC}"
        fi
        echo ""
    fi

    echo ""
}

# función para generar un certificado SSL para el VirtualHost por defecto
generate_ssl_for_default_virtualhost() {
    local domains=(
        "webserver.local"
        "phpmyadmin.local"
    )

    if [ "$SSL_ENABLED" = true ]; then
        echo -e "${BLUE}Generando certificados SSL predeterminados...${NC}"

        mkdir -p "$SSL_DIR"

        for domain in "${domains[@]}"; do
            local cert_file="$SSL_DIR/$domain.crt"
            local key_file="$SSL_DIR/$domain.key"

            echo -e "${YELLOW}Generando certificado para: $domain.${NC}"
            mkcert -cert-file "$cert_file" -key-file "$key_file" "$domain"
            # mkcert -cert-file "webserver.local.crt" -key-file "webserver.local.key" webserver.local "*.webserver.local" localhost 127.0.0.1 ::1

            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Certificado creado para $domain.${NC}"
            else
                echo -e "${RED}Error al generar certificado para $domain.${NC}"
            fi
        done
    else
        echo -e "${YELLOW}SSL no está habilitado. Omitiendo generación de certificados.${NC}"
    fi
}

# Función para generar un VirtualHost para webServer
generate_apache_default_virtualhost() {
    if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
        echo -e "${BLUE}Configurando VirtualHost para webServer en Apache...${NC}"
        VHOST_CONF="$ETC_DIR/apache2/sites-enabled/webserver.local.conf"
        VHOST_DIR="$WEB_SERVER_DIR/www/"
        TEMPLATE_FILE="$WEB_SERVER_DIR/templates/apache/default-vhost.tpl"

        # Crear el directorio de configuración si no existe
        mkdir -p "$(dirname "$VHOST_CONF")"

        # Reemplazar las variables del template
        sed \
            -e "s|{{VIRTUAL_HOST_NAME}}|$VIRTUAL_HOST_NAME|g" \
            -e "s|{{WEB_SERVER_DIR}}|$WEB_SERVER_DIR|g" \
            -e "s|{{LOGS_DIR}}|$LOGS_DIR|g" \
            -e "s|{{SSL_DIR}}|$SSL_DIR|g" \
            "$TEMPLATE_FILE" > "$VHOST_CONF"

        echo -e "${GREEN}VirtualHost de webServer configurado en:${NC} $VHOST_CONF"
    else
        echo -e "${BLUE}Configurando VirtualHost para webServer en Apache...${NC}"
    fi
}

# Función para generar un VirtualHost para phpMyAdmin
generate_apache_phpmyadmin_virtualhost() {
    if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
        echo -e "${BLUE}Configurando VirtualHost para phpMyAdmin en Apache...${NC}"
        VHOST_CONF="$ETC_DIR/apache2/sites-enabled/phpmyadmin.local.conf"
        TEMPLATE_FILE="$WEB_SERVER_DIR/templates/apache/phpmyadmin-vhost.tpl"

        mkdir -p "$(dirname "$VHOST_CONF")"

        # Reemplazar variables del template
        sed \
            -e "s|{{VIRTUAL_HOST_NAME}}|$VIRTUAL_HOST_NAME|g" \
            -e "s|{{WEB_SERVER_DIR}}|$WEB_SERVER_DIR|g" \
            -e "s|{{LOGS_DIR}}|$LOGS_DIR|g" \
            -e "s|{{SSL_DIR}}|$SSL_DIR|g" \
            "$TEMPLATE_FILE" > "$VHOST_CONF"

        echo -e "${GREEN}VirtualHost de phpMyAdmin configurado en:${NC} $VHOST_CONF"
    else
        echo -e "${BLUE}Configurando VirtualHost para phpMyAdmin en Apache...${NC}"
    fi
}

generate_nginx_vhost_phpmyadmin() {
    echo -e "${BLUE}Configurando VirtualHost para phpMyAdmin en Nginx...${NC}"
}

# Función para configurar el Virtual Host
configure_virtual_host() {
    # Crear el directorio del virtual host
    read -p "¿Deseas configurar un virtual host? (s/n, por defecto n): " add_vhost
    if [[ "$add_vhost" =~ ^[SsYy]$ ]]; then
        read -p "Introduce el nombre del virtual host (ej: miproyecto.local): " VIRTUAL_HOST_NAME

        VHOST_DIR="$WEB_SERVER_DIR/www/$VIRTUAL_HOST_NAME/public"
        mkdir -p "$VHOST_DIR"
        echo "<?php echo '<h1>Bienvenido a $VIRTUAL_HOST_NAME</h1>'; ?>" > "$VHOST_DIR/index.php"

        if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
            # --- Apache Virtual Host ---
            APACHE_VHOST_CONF="$ETC_DIR/apache2/sites-enabled/$VIRTUAL_HOST_NAME.conf"
            mkdir -p "$(dirname "$APACHE_VHOST_CONF")"

            cat > "$APACHE_VHOST_CONF" <<EOF
# Virtual host para $VIRTUAL_HOST_NAME
<VirtualHost *:80>
    ServerName $VIRTUAL_HOST_NAME
    ServerAlias www.$VIRTUAL_HOST_NAME
    DocumentRoot "$VHOST_DIR"
    <Directory "$VHOST_DIR">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-error.log"
    CustomLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-access.log" combined
</VirtualHost>
EOF

            echo -e "${GREEN}Virtual host Apache creado: $APACHE_VHOST_CONF${NC}"
            "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/bin/httpd.exe" -k restart

        else
            # --- Nginx Virtual Host ---
            NGINX_VHOST_CONF="$ETC_DIR/nginx/sites-enabled/$VIRTUAL_HOST_NAME.conf"
            mkdir -p "$(dirname "$NGINX_VHOST_CONF")"

            cat > "$NGINX_VHOST_CONF" <<EOF
server {
    listen 80;
    server_name $VIRTUAL_HOST_NAME www.$VIRTUAL_HOST_NAME;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $VIRTUAL_HOST_NAME www.$VIRTUAL_HOST_NAME;

    ssl_certificate      $SSL_DIR/$VIRTUAL_HOST_NAME.crt;
    ssl_certificate_key  $SSL_DIR/$VIRTUAL_HOST_NAME.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    root $VHOST_DIR;
    index index.php index.html index.htm;

    access_log $LOGS_DIR/$VIRTUAL_HOST_NAME-access.log;
    error_log  $LOGS_DIR/$VIRTUAL_HOST_NAME-error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include        fastcgi_params;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
        try_files \$uri =404;
    }

    location ~ /\.(env|git|svn|htaccess|htpasswd) {
        deny all;
        return 403;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        log_not_found off;
        access_log off;
    }

    location ~ /\. {
        deny all;
        return 403;
    }
}
EOF
            echo -e "${GREEN}Virtual host Nginx creado: $NGINX_VHOST_CONF${NC}"
            taskkill /IM nginx.exe /F
            start "Nginx" "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/nginx.exe"
        fi

        # Configurar archivo hosts
        configure_hosts_file

        # Configurar SSL
        configure_ssl
    fi
}

# Función para configurar el archivo hosts de Windows
configure_hosts_file() {
    local hosts_file="C:/Windows/System32/drivers/etc/hosts"
    local entry="127.0.0.1      $VIRTUAL_HOST_NAME      # WebServer"

    echo -e "${BLUE}Configurando el archivo hosts...${NC}"

    # Verificar si ya existe
    if grep -q "$VIRTUAL_HOST_NAME" "$hosts_file"; then
        echo -e "${YELLOW}El dominio $VIRTUAL_HOST_NAME ya existe en el archivo hosts. No se agregará de nuevo.${NC}"
    else
        echo "$entry" >> "$hosts_file"
        echo -e "${GREEN}Entrada agregada al archivo hosts.${NC}"
    fi
}

# Función para configurar SSL
configure_ssl() {
    read -p "¿Deseas configurar SSL para un virtual host? (s/n, por defecto n): " add_ssl
    if [[ "$add_ssl" =~ ^[SsYy]$ ]]; then
        SSL_ENABLED=true

        # Solicitar al usuario el nombre del virtual host
        read -p "Introduce el nombre del virtual host para SSL (ej: miproyecto.local): " VIRTUAL_HOST_NAME

        # Validar que se haya ingresado un nombre
        if [ -z "$VIRTUAL_HOST_NAME" ]; then
            echo -e "${RED}Error: Debes especificar un nombre de virtual host${NC}"
            return 1
        fi

        # Para Windows (Git Bash), usaremos mkcert para SSL local
        echo -e "${BLUE}Configurando SSL local para $VIRTUAL_HOST_NAME con mkcert...${NC}"

        # if ! command -v choco &> /dev/null; then
            # echo -e "${RED}Chocolatey no está instalado.${NC}"
            # if command -v winget &> /dev/null; then
                # echo -e "${YELLOW}Intentando con winget...${NC}"
                # winget install -e --id Microsoft.Winget.Cli --source msstore # Asegúrate que winget este instalado
                # winget install -y mkcert
            # else
                # echo -e "${RED}Chocolatey no está instalado. Instala mkcert manualmente.${NC}"
                # return 1
            # fi
        # fi

        # Instalar mkcert si no está instalado
        if ! command -v mkcert &> /dev/null; then
                install_mkcert
            if command -v choco &> /dev/null; then
                choco install -y mkcert
            else
                echo -e "${RED}Error: Chocolatey no está instalado. Instala mkcert manualmente.${NC}"
                return 1
            fi
        fi

        # Crear directorio ssl en bin si no existe
        mkdir -p "$SSL_DIR/"

        # Crear certificados para el virtual host en etc/ssl
        echo -e "${BLUE}Generando certificados para $VIRTUAL_HOST_NAME...${NC}"
        mkcert -cert-file "$SSL_DIR/$VIRTUAL_HOST_NAME.crt" -key-file "$SSL_DIR/$VIRTUAL_HOST_NAME.key" "$VIRTUAL_HOST_NAME"

        # Configurar el servidor web con SSL
        if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
            # Configurar Apache para SSL
            echo -e "${BLUE}Configurando Apache para $VIRTUAL_HOST_NAME...${NC}"

            VIRTUAL_HOST_NAME_CONF="$ETC_DIR/apache2/sites-enabled/$VIRTUAL_HOST_NAME.conf"

            rm -f "$VIRTUAL_HOST_NAME_CONF"

            cat > "$VIRTUAL_HOST_NAME_CONF" <<EOF
# Configuración HTTP (redirección a HTTPS)
<VirtualHost *:80>
    ServerName $VIRTUAL_HOST_NAME
    Redirect permanent / https://$VIRTUAL_HOST_NAME
</VirtualHost>

# Virtual host para $VIRTUAL_HOST_NAME
<VirtualHost *:80>
    ServerName $VIRTUAL_HOST_NAME
    ServerAlias *.$VIRTUAL_HOST_NAME
    DocumentRoot "$WEB_SERVER_DIR/www/$VIRTUAL_HOST_NAME/public"
    <Directory "$WEB_SERVER_DIR/www/$VIRTUAL_HOST_NAME/public">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-error.log"
    CustomLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-access.log" combined
</VirtualHost>

# Configuración HTTPS para $VIRTUAL_HOST_NAME
<VirtualHost *:443>
    ServerName $VIRTUAL_HOST_NAME
    ServerAlias *.$VIRTUAL_HOST_NAME
    DocumentRoot "$WEB_SERVER_DIR/www/$VIRTUAL_HOST_NAME/public"
    <Directory "$WEB_SERVER_DIR/www/$VIRTUAL_HOST_NAME/public">
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-error.log"
    CustomLog "$LOGS_DIR/$VIRTUAL_HOST_NAME-access.log" combined
    SSLEngine on
    SSLCertificateFile $SSL_DIR/$VIRTUAL_HOST_NAME.crt
    SSLCertificateKeyFile $SSL_DIR/$VIRTUAL_HOST_NAME.key
</VirtualHost>
EOF

            # Reiniciar
            if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
                read -p "¿Deseas reiniciar Apache ahora? (s/n, por defecto s): " restart_apache
                if [[ "$restart_apache" =~ ^[SsYy]$ ]]; then
                    "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/bin/httpd.exe" -k restart
                    echo -e "${GREEN}Apache reiniciado.${NC}"
                fi
            elif [ "$INSTALLED_WEB_SERVER_ENGINE" = "Nginx" ]; then
                read -p "¿Deseas reiniciar Nginx ahora? (s/n, por defecto s): " restart_nginx
                if [[ "$restart_nginx" =~ ^[SsYy]$ ]]; then
                    taskkill /IM nginx.exe /F
                    start "Nginx" "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/nginx.exe"
                    echo -e "${GREEN}Nginx reiniciado.${NC}"
                fi
            fi
        else
            # Configurar Nginx para SSL
            echo -e "${BLUE}Configurando Nginx para $VIRTUAL_HOST_NAME...${NC}"

            NGINX_VHOST_CONF="$ETC_DIR/nginx/sites-enabled/$VIRTUAL_HOST_NAME.conf"

            rm -f "$NGINX_VHOST_CONF"

            # Configuración HTTP (redirección a HTTPS)
            cat > "$NGINX_VHOST_CONF" <<EOF
# Configuración HTTP (redirección a HTTPS)
server {
    listen 80;
    server_name $VIRTUAL_HOST_NAME www.$VIRTUAL_HOST_NAME;
    return 301 https://\$host\$request_uri;
}

# Configuración HTTPS
server {
    listen 443 ssl http2;
    server_name $VIRTUAL_HOST_NAME www.$VIRTUAL_HOST_NAME;

    ssl_certificate      $SSL_DIR/$VIRTUAL_HOST_NAME.crt;
    ssl_certificate_key  $SSL_DIR/$VIRTUAL_HOST_NAME.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    root $VHOST_DIR;
    index index.php index.html index.htm;

    access_log $LOGS_DIR/$VIRTUAL_HOST_NAME-access.log;
    error_log  $LOGS_DIR/$VIRTUAL_HOST_NAME-error.log;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include        fastcgi_params;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
        try_files \$uri =404;
    }

    location ~ /\.(env|git|svn|htaccess|htpasswd) {
        deny all;
        return 403;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        log_not_found off;
        access_log off;
    }

    location ~ /\. {
        deny all;
        return 403;
    }
}
EOF

            # Reiniciar Nginx
            echo -e "${BLUE}Reiniciando Nginx...${NC}"
            taskkill /IM nginx.exe /F
            start "Nginx" "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/nginx.exe"
        fi

        echo -e "${GREEN}Configuración SSL completada para $VIRTUAL_HOST_NAME${NC}"
        echo -e "${YELLOW}Certificados almacenados en: $SSL_DIR/${NC}"
        echo -e "${YELLOW}Acceso seguro: https://$VIRTUAL_HOST_NAME${NC}"
        echo -e "${YELLOW}Nota: Asegúrate de tener mkcert instalado en tu navegador para SSL local.${NC}"
    fi
}

# Función para generar vhosts por defecto
generate_default_nginx_vhosts() {
    local sites_enabled_path="$ETC_DIR/nginx/sites-enabled"
    local templates_path="$WEB_SERVER_DIR/templates/nginx"
    local default_root="$WEB_SERVER_DIR/www"
    local default_index="index.php index.html index.htm"

    echo -e "${YELLOW}Generando nuevos vhosts personalizados...${NC}"
    # mkdir -p "$sites_enabled_path"

    # Lista de dominios
    local domains=(
        "webserver.local"
        "phpmyadmin.local"
    )

    for domain in "${domains[@]}"; do
        local name="${domain%%.*}" # sin .local
        local conf_file="$sites_enabled_path/${name}.conf"
        local tpl_file=""
        local root_dir=""

        case "$domain" in
            webserver.local)
                tpl_file="$templates_path/webserver.tpl"
                root_dir="$WEB_SERVER_DIR/www"
                ;;
            phpmyadmin.local)
                tpl_file="$templates_path/phpmyadmin.tpl"
                root_dir="$WEB_SERVER_DIR/etc/apps/phpmyadmin"
                ;;
            *)
                tpl_file="$templates_path/default.tpl"
                root_dir="$default_root/$name/public"
                ;;
        esac

        if [ -f "$tpl_file" ]; then
            < "$tpl_file" \
            sed "s|{{DOMAIN}}|$domain|g" |
            sed "s|{{ROOT}}|$root_dir|g" |
            sed "s|{{CERT}}|$domain|g" |
            sed "s|{{INDEX}}|$default_index|g" \
            > "$conf_file"

            echo "Generado: $conf_file."
        else
            echo -e "${RED} Plantilla no encontrada para $domain ($tpl_file).${NC}"
        fi
    done
}

# Función para instalar mkcert
install_mkcert() {
    echo -e "${BLUE}Verificando mkcert...${NC}"

    # Verificar si mkcert está instalado
    if ! command -v mkcert &> /dev/null; then
        echo -e "${YELLOW}Instalando mkcert...${NC}"
        if command -v choco &> /dev/null; then
            choco install -y mkcert
        else
            echo -e "${RED}Error: Chocolatey no está instalado. Instala mkcert manualmente.${NC}"
            return 1
        fi
    else
        echo -e "${GREEN}mkcert ya está instalado.${NC}"
    fi

    # Crear CA local si no existe
    local ca_root
    ca_root="$(mkcert -CAROOT)/rootCA.pem"
    if [ ! -f "$ca_root" ]; then
        echo -e "${YELLOW}Creando Autoridad Certificadora local (CA)...${NC}"
        mkcert -install
    else
        echo -e "${GREEN}CA local ya existe en: $ca_root${NC}"
    fi
}

# Función para instalar Git
install_git() {
    echo -e "${BLUE}Instalando Git...${NC}"
    git_version=$(get_version "Git" $DEFAULT_GIT_VERSION)

    # Para Windows, descargar e instalar Git
    git_exe="Git-$git_version-64-bit.exe"
    git_url="https://github.com/git-for-windows/git/releases/download/v$git_version.windows.1/$git_exe"
    # https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-64-bit.exe

    download_file "$git_url" "$git_exe" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$git_exe" ]; then
        echo -e "${BLUE}Instalando Git...${NC}"
        # Instalar Git en modo silencioso con las opciones predeterminadas
        "$DOWNLOADS_DIR/$git_exe" /SILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"

        # Agregar Git al PATH (normalmente se hace automáticamente durante la instalación)
        add_to_path "C:\\Program Files\\Git\\bin"

        echo -e "${GREEN}Git $git_version instalado correctamente.${NC}"
    else
        echo -e "${RED}Error al descargar Git.${NC}"
        return 1
    fi

    git --version
}

# Función para reemplazar variables en una plantilla y generar el archivo final
render_template() {
    local template_file="$1"
    local output_file="$2"

    # Leemos la plantilla, reemplazamos variables conocidas
    sed \
        -e "s|{{YEAR}}|$(date +%Y)|g" \
        -e "s|{{DOCROOT}}|${WEB_SERVER_DIR}/www|g" \
        "$template_file" > "$output_file"
}

# Función para crear archivos de prueba usando plantillas
create_test_files() {
    echo -e "${BLUE}Creando archivos de prueba en $WEB_SERVER_DIR/www...${NC}"

    mkdir -p "$WEB_SERVER_DIR/www"

    # Renderizar y copiar las plantillas
    render_template "./plantillas/index.php.tpl" "$WEB_SERVER_DIR/www/index.php"
    render_template "./plantillas/phpinfo.php.tpl" "$WEB_SERVER_DIR/www/phpinfo.php"

    echo -e "${GREEN}Archivos de prueba creados en $WEB_SERVER_DIR/www/${NC}"
    echo -e "${YELLOW}Accede a http://localhost/index.php para ver la información del servidor${NC}"
    echo -e "${YELLOW}Accede a http://localhost/phpinfo.php para ver phpinfo() completo${NC}"
}


# Función para crear archivos de prueba
create_test_fildes() {
    echo -e "${BLUE}Creando archivos de prueba en $WEB_SERVER_DIR/www...${NC}"

    # Archivo index.php con información del servidor
    cat > "$WEB_SERVER_DIR/www/index.php" << 'EOF'
rrrrr
EOF

    # Archivo phpinfo.php
    cat > "$WEB_SERVER_DIR/www/phpinfo.php" << 'EOF'
gg
EOF

    echo -e "${GREEN}Archivos de prueba creados en $WEB_SERVER_DIR/www/${NC}"
    echo -e "${YELLOW}Accede a http://localhost/index.php para ver la información del servidor${NC}"
    echo -e "${YELLOW}Accede a http://localhost/phpinfo.php para ver phpinfo() completo${NC}"
}

# Función para agregar a las variables de entorno
add_to_path() {
    local path_to_add=$1

    # Verificar si la ruta ya está en el PATH
    if [[ ":$PATH:" != *":$path_to_add:"* ]]; then
        echo -e "${BLUE}Agregando $path_to_add a las variables de entorno...${NC}"

        # Para Git Bash en Windows
        if [ -f ~/.bash_profile ]; then
            # Verificar si ya existe la ruta en .bash_profile
            if ! grep -q "$path_to_add" ~/.bash_profile; then
                echo "export PATH=\"\$PATH:$path_to_add\"" >> ~/.bash_profile
                source ~/.bash_profile
            else
                echo -e "${YELLOW}La ruta $path_to_add ya existe en .bash_profile${NC}"
            fi
        else
            # Verificar si ya existe la ruta en .bashrc
            if ! grep -q "$path_to_add" ~/.bashrc; then
                echo "export PATH=\"\$PATH:$path_to_add\"" >> ~/.bashrc
                source ~/.bashrc
            else
                echo -e "${YELLOW}La ruta $path_to_add ya existe en .bashrc${NC}"
            fi
        fi

        # También agregar al PATH del sistema Windows
        if [[ $path_to_add == *":"* ]]; then
            # Es una ruta de Windows (contiene ':')
            powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User) + ';$path_to_add', [EnvironmentVariableTarget]::User)"
        else
            # Es una ruta de Unix (convertir a formato Windows)
            win_path=$(echo "$path_to_add" | sed 's/^\///' | sed 's/\//\\/g')
            win_path="C:\\$win_path"
            powershell -Command "[Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH', [EnvironmentVariableTarget]::User) + ';$win_path', [EnvironmentVariableTarget]::User)"
        fi

        echo -e "${GREEN}Ruta $path_to_add agregada al PATH${NC}"
    else
        echo -e "${YELLOW}La ruta $path_to_add ya está en el PATH${NC}"
    fi
}

# Función para descargar archivos
download_file() {
    local url=$1
    local filename=$2
    local dest_dir=$3

    echo -e "${BLUE}Descargando $filename...${NC}"

    mkdir -p "$dest_dir" || {
        echo -e "${RED}Error al crear directorio de descarga: $dest_dir${NC}"
        return 1
    }

    if [ ! -f "$dest_dir/$filename" ]; then
        # Intentar primero con wget
        if command -v wget &> /dev/null; then
            wget -q --show-progress --timeout=60 --tries=3 --waitretry=5 -O "$dest_dir/$filename" "$url" || {
            # wget -q --show-progress -O "$dest_dir/$filename" "$url" || {
                echo -e "${YELLOW}wget falló. Intentando con curl...${NC}"
                # Si wget falla, intentar con curl
                if command -v curl &> /dev/null; then
                    curl -L --retry 3 --max-time 60 --progress-bar --output "$dest_dir/$filename" "$url" || {
                    # curl -L --output "$dest_dir/$filename" "$url" || {
                        echo -e "${RED}Error al descargar $filename.${NC}"
                        return 1
                    }
                else
                    echo -e "${RED}No se encontró ni wget ni curl para descargar.${NC}"
                    return 1
                fi
            }
        elif command -v curl &> /dev/null; then
            curl -L --output "$dest_dir/$filename" "$url" || {
                echo -e "${RED}Error al descargar $filename.${NC}"
                return 1
            }
        else
            echo -e "${RED}No se encontró wget ni curl para descargar archivos.${NC}"
            return 1
        fi
        echo -e "${GREEN}Descarga completada: $filename.${NC}"
    else
        echo -e "${YELLOW}El archivo $filename ya existe.${NC}"
    fi
}

# Función para mostrar el menú de selección
show_menu() {
    clear
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║      MENÚ DE INSTALACIÓN DE SERVIDOR WEB      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Directorio base: ${BLUE}$WEB_SERVER_DIR${NC}"
    echo ""
    echo -e "${YELLOW}[1].${NC} Instalar Git"
    echo -e "${YELLOW}[2].${NC} Instalar PHP"
    echo -e "${YELLOW}[3].${NC} Instalar Python"
    echo -e "${YELLOW}[4].${NC} Instalar Node.js"
    echo -e "${YELLOW}[5].${NC} Instalar Base de Datos (MySQL/MariaDB)"
    echo -e "${YELLOW}[6].${NC} Instalar phpMyAdmin"
    echo -e "${YELLOW}[7].${NC} Instalar Apache"
    echo -e "${YELLOW}[8].${NC} Instalar Nginx"
    echo -e "${YELLOW}[9].${NC} Instalar Composer"
    echo -e "${YELLOW}[10].${NC} Instalar TODOS los componentes"
    echo -e "${YELLOW}[11].${NC} Configurar integración entre componentes"
    echo -e "${YELLOW}[12].${NC} Crear scripts de arranque"
    echo -e "${YELLOW}[13].${NC} Configurar Virtual Host"
    echo -e "${YELLOW}[14].${NC} Configurar SSL"
    echo -e "${YELLOW}[15].${NC} Mostrar resumen de instalación"
    echo -e "${YELLOW}[16].${NC} Instalar Redis y Memcached"
    echo -e "${YELLOW}[17].${NC} Instalar extensiones útiles (imagick, intl, etc.)"
    echo -e "${YELLOW}[18].${NC} Crear Backup del entorno"
    echo -e "${YELLOW}[19].${NC} Desinstalar / Limpiar entorno"
    echo -e "${YELLOW}[20].${NC} Salir"
    echo ""
}

# Función para obtener la versión deseada
get_version() {
    local component=$1
    local default_version=$2
    read -p "Introduce la versión de $component (por defecto $default_version): " version
    version=${version:-$default_version}
    echo "$version"
}

# Función para instalar PHP
install_php() {
    echo -e "${BLUE}Instalando PHP...${NC}"
    php_version=$(get_version "PHP" $DEFAULT_PHP_VERSION)

    # Para Git Bash, descargar e instalar manualmente
    php_zip="php-$php_version-Win32-vs16-x64.zip"
    php_url="https://windows.php.net/downloads/releases/$php_zip"
    # https://windows.php.net/downloads/releases/php-8.3.20-Win32-vs16-x64.zip

    download_file "$php_url" "$php_zip" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$php_zip" ]; then
        echo -e "${BLUE}Descomprimiendo PHP...${NC}"
        unzip -q "$DOWNLOADS_DIR/$php_zip" -d "$BIN_DIR/php/$php_version"

        # Agregar PHP al PATH
        add_to_path "$BIN_DIR/php/$php_version"

        ini_file="$BIN_DIR/php/$php_version/php.ini"

        # Copiar archivo de configuración
        cp "$BIN_DIR/php/$php_version/php.ini-development" "$ini_file"

        # Habilitar extensiones comunes
        sed -i 's/;extension=curl/extension=curl/' "$ini_file"
        sed -i 's/;extension=gd/extension=gd/' "$ini_file"
        sed -i 's/;extension=mbstring/extension=mbstring/' "$ini_file"
        sed -i 's/;extension=mysqli/extension=mysqli/' "$ini_file"
        sed -i 's/;extension=openssl/extension=openssl/' "$ini_file"
        sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' "$ini_file"
        sed -i 's/;extension=imap/extension=imap/' "$ini_file"
        sed -i 's/;extension=xsl/extension=xsl/' "$ini_file"
        sed -i 's/;extension=zip/extension=zip/' "$ini_file"
        sed -i 's/;extension=intl/extension=intl/' "$ini_file"

        # enable_dl = Off

        # Establecer la ruta de extension_dir en php.ini
        sed -i "s|;extension_dir = \"ext\"|extension_dir = \"$WEB_SERVER_DIR/bin/php/$php_version/ext\"|" "$ini_file"
        sed -i "s|^;session.save_path = \"/tmp\"|session.save_path = \"$WEB_SERVER_DIR/tmp\"|" "$ini_file"

        # Establecer error_log
        sed -i "s|^;error_log = php_errors.log|error_log = \"$WEB_SERVER_DIR/logs/php_errors.log\"|" "$ini_file"

        # Ajustes de rendimiento y límites
        sed -i 's/^max_execution_time = .*/max_execution_time = 36000/' "$ini_file"
        sed -i 's/^;max_input_vars = .*/max_input_vars = 3000/' "$ini_file"
        sed -i 's/^memory_limit = .*/memory_limit = 512M/' "$ini_file"
        sed -i 's/^post_max_size = .*/post_max_size = 2G/' "$ini_file"
        sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 2G/' "$ini_file"
        sed -i 's/^session.gc_maxlifetime = .*/session.gc_maxlifetime = 36000/' "$ini_file"
        # sed -i 's/^;date.timezone = .*/date.timezone = "America/Costa_Rica"/' "$ini_file"
        sed -i 's|^;date.timezone =|date.timezone = "America/Costa_Rica"|' "$ini_file"

        # Guardar versión instalada
        update_env_var "INSTALLED_PHP_VERSION" "$php_version"
        update_env_var "INSTALLED_PHP_DIR" "$BIN_DIR/php/$php_version/"

        echo -e "${GREEN}PHP $php_version instalado correctamente en $BIN_DIR/php/$php_version.${NC}"
    else
        echo -e "${RED}Error al descargar PHP.${NC}"
        return 1
    fi

    php -v
}

# Función para instalar Composer
install_composer() {
    echo -e "${BLUE}Instalando Composer...${NC}"
    composer_version=$(get_version "Composer" $DEFAULT_COMPOSER_VERSION)

    # Para Git Bash en Windows
    echo -e "${BLUE}Descargando instalador de Composer para Windows...${NC}"

    # Crear el directorio de descargas
    mkdir -p "$DOWNLOADS_DIR" || {
        echo -e "${RED}Error: No se pudo crear el directorio de downloads.${NC}"
        return 1
    }

    #
    composer_exe="Composer-Setup.exe"
    composer_url="https://getcomposer.org/$composer_exe"

    download_file "$composer_url" "$composer_exe" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$composer_exe" ]; then
        echo -e "${BLUE}Instalando Composer...${NC}"
        # Instalar Composer en modo silencioso con las opciones predeterminadas
        "$DOWNLOADS_DIR/$composer_exe" /SILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"

        # Agregar Composer al PATH (normalmente se hace automáticamente durante la instalación)
        add_to_path "C:\Users\\$USER_HOME_DIR\AppData\Roaming\Composer\vendor\bin"

        echo -e "${GREEN}Composer $composer_version instalado correctamente.${NC}"

        # Verificar la instalación
        if command -v composer &> /dev/null; then
            composer --version
        else
            echo -e "${YELLOW}Nota: Es posible que necesites cerrar y reabrir la terminal para que los cambios surtan efecto.${NC}"
        fi
    else
        echo -e "${RED}Error al descargar Composer.${NC}"
        return 1
    fi
}

# Función para instalar Python
install_python() {
    echo -e "${BLUE}Instalando Python...${NC}"
    python_version=$(get_version "Python" $DEFAULT_PYTHON_VERSION)

    # Para Git Bash, descargar e instalar manualmente
    python_exe="python-$python_version-amd64.exe"
    python_url="https://www.python.org/ftp/python/$python_version/$python_exe"
    # https://www.python.org/ftp/python/3.13.3/python-3.13.3-amd64.exe

    download_file "$python_url" "$python_exe" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$python_exe" ]; then
        echo -e "${BLUE}Instalando Python...${NC}"
        # Instalar Python
        "$DOWNLOADS_DIR/$python_exe"

        echo -e "${GREEN}Python $python_version instalado correctamente.${NC}"
    else
        echo -e "${RED}Error al descargar Python.${NC}"
        return 1
    fi

    python --version
}

# Función para instalar Node.js
install_node() {
    echo -e "${BLUE}Instalando Node.js...${NC}"
    node_version=$(get_version "Node.js" $DEFAULT_NODE_VERSION)

    # Para Git Bash, descargar e instalar manualmente
    node_exe="node-v$node_version-x64.msi"
    node_url="https://nodejs.org/dist/v$node_version/$node_exe"
    # https://nodejs.org/dist/v22.15.0/node-v22.15.0-x64.msi

    download_file "$node_url" "$node_exe" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$node_exe" ]; then
        echo -e "${BLUE}Instalando Node.js...${NC}"
        # Instalar Node.js

        powershell.exe Start-Process -FilePath "\"$DOWNLOADS_DIR/$node_exe\""

        echo -e "${GREEN}Node.js $node_version instalado correctamente.${NC}"
    else
        echo -e "${RED}Error al descargar Node.js.${NC}"
        return 1
    fi

    # Verificar la instalación
    node --version
    npm --version
}

# Función para instalar MariaDB
install_database_prueba() {
    db_version=$(get_version "$INSTALLED_DB_ENGINE" $DEFAULT_DB_VERSION)
    mariadb_zip="mariadb-$db_version-winx64.zip"
    mariadb_url="https://downloads.mariadb.org/interstitial/mariadb-$db_version/winx64-packages/$mariadb_zip"

    # Descargar MariaDB
    # download_file "$mariadb_url" "$mariadb_zip" "$DOWNLOADS_DIR"

    # Descomprimir
    echo -e "${BLUE}Descomprimiendo MariaDB...${NC}"
    unzip -q "$DOWNLOADS_DIR/$mariadb_zip" -d "$BIN_DIR/mariadb"
    mv "$BIN_DIR/mariadb/mariadb-$db_version-winx64" "$BIN_DIR/mariadb/$db_version"

    # --- Inicializar la base de datos ---
    echo -e "${BLUE}Inicializando MariaDB...${NC}"
    # "$BIN_DIR/mariadb/$db_version/bin/mysql_install_db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --password=root --service=MariaDB
    "$BIN_DIR/mariadb/$db_version/bin/mariadb-install-db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --password=root --service=MariaDB

    if ! "$BIN_DIR/mariadb/$db_version/bin/mariadb-install-db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --password=root --service=MariaDB; then
        echo -e "${RED}Error al inicializar la base de datos de MariaDB. Revisa los logs si existen.${NC}"
        #return 1
    fi
    echo -e "${GREEN}Inicialización completada.${NC}"

    # Agregar al PATH
    #add_to_path "$mariadb_bin"

    # --- Instalar y Iniciar el servicio ---
    echo -e "${BLUE}Instalando y iniciando el servicio de MariaDB...${NC}"
    "$BIN_DIR/mariadb/$db_version/bin/mariadbd.exe" --install MariaDB --console > "$WEB_SERVER_DIR/logs/mariadb.log" 2>&1 &
    if ! "$BIN_DIR/mariadb/$db_version/bin/mariadbd.exe" --install MariaDB; then
        echo -e "${RED}Error al instalar el servicio de MariaDB.${NC}"
        #return 1
    fi

    if ! net start MariaDB; then
        echo -e "${RED}Error al iniciar el servicio de MariaDB. Verifica que el servicio se haya instalado correctamente.${NC}"
        #return 1
    fi
    echo -e "${GREEN}Servicio de MariaDB instalado e iniciado.${NC}"

    # --- Verificar estado ---
    sleep 2
    if sc query MariaDB | grep "RUNNING"; then
        echo -e "${GREEN}MariaDB se ha instalado y está en ejecución.${NC}"
        echo -e "Usuario: root | Contraseña: root (¡cambiala después por seguridad!)${NC}"
    else
        echo -e "${RED}Error: El servicio de MariaDB no se está ejecutando. Revisa los logs del servicio de Windows.${NC}"
        #return 1
    fi

    # Instalar MariaDB
    echo -e "${BLUE}Instalando MariaDB $DEFAULT_DB_VERSION...${NC}"
    #install_mariadb "$DEFAULT_DB_VERSION"

    echo -e "${GREEN}¡Instalación completada!${NC}"
}


# Función para instalar la base de datos
install_database() {
    echo -e "${BLUE}Instalando Base de Datos...${NC}"
    read -p "¿Qué motor de base de datos prefieres? (MySQL/MariaDB, por defecto $DEFAULT_DB_ENGINE): " db_engine
    INSTALLED_DB_ENGINE=${db_engine:-$DEFAULT_DB_ENGINE}

    db_version=$(get_version "$INSTALLED_DB_ENGINE" $DEFAULT_DB_VERSION)

    if [ "$INSTALLED_DB_ENGINE" = "MySQL" ]; then
        mysql_zip="mysql-$db_version-winx64.zip"
        mysql_url="https://dev.mysql.com/get/Downloads/MySQL-$db_version/$mysql_zip"

        download_file "$mysql_url" "$mysql_zip" "$DOWNLOADS_DIR"

        if [ -f "$DOWNLOADS_DIR/$mysql_zip" ]; then
            echo -e "${BLUE}Descomprimiendo MySQL...${NC}"
            unzip -q "$DOWNLOADS_DIR/$mysql_zip" -d "$BIN_DIR/mysql"
            mv "$BIN_DIR/mysql/mysql-$db_version-winx64" "$BIN_DIR/mysql/$db_version"
            add_to_path "$BIN_DIR/mysql/$db_version/bin"
        fi
    else
        mariadb_zip="mariadb-$db_version-winx64.zip"
        mariadb_url="https://downloads.mariadb.org/interstitial/mariadb-$db_version/winx64-packages/$mariadb_zip"

        download_file "$mariadb_url" "$mariadb_zip" "$DOWNLOADS_DIR"

        if [ -f "$DOWNLOADS_DIR/$mariadb_zip" ]; then
            echo -e "${BLUE}Descomprimiendo MariaDB...${NC}"
            unzip -q "$DOWNLOADS_DIR/$mariadb_zip" -d "$BIN_DIR/mariadb"
            mv "$BIN_DIR/mariadb/mariadb-$db_version-winx64" "$BIN_DIR/mariadb/$db_version"

            # Guardar versión instalada
            update_env_var "DEFAULT_DB_ENGINE" "MariaDB"
            update_env_var "DEFAULT_DB_VERSION" "$db_version"

            # Iniciar y configurar MariaDB
            MARIADB_BIN="$BIN_DIR/mariadb/$db_version"

            # Crear carpeta data si no existe
            if [ ! -d "$MARIADB_BIN/data" ]; then
                #mkdir -p "$MARIADB_BIN/data"
                log "Carpeta data creada: $MARIADB_BIN/data"
            fi

            # Inicializar base de datos si no existe la carpeta 'data'

            #--defaults-extra-file=my.ini

            if [ ! -d "$BIN_DIR/mariadb/$db_version/data/mysql" ]; then
                echo -e "${BLUE}Inicializando la base de datos MariaDB...${NC}"
                # "$BIN_DIR/mariadb/$db_version/bin/mysqld.exe" --initialize-insecure --basedir="$BIN_DIR/mariadb/$db_version" --datadir="$BIN_DIR/mariadb/$db_version/data" --console
                # "$BIN_DIR/mariadb/$db_version/bin/mariadb-install-db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --basedir="$BIN_DIR/mariadb/$db_version" --auth-root-authentication-method=normal
                # "$BIN_DIR/mariadb/$db_version/bin/mysqld.exe" --basedir="$BIN_DIR/mariadb/$db_version" --datadir="$BIN_DIR/mariadb/$db_version/data" --console
                # "$BIN_DIR/mariadb/$db_version/bin/mariadb-install-db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --service=MariaDB --password=root
                "$BIN_DIR/mariadb/$db_version/bin/mariadb-install-db.exe" --datadir="$BIN_DIR/mariadb/$db_version/data" --password=root
                echo -e "${GREEN}Base de datos inicializada sin contraseña para root.${NC}"
            fi

            # Crear my.ini si no existe
            #create_mariadb_ini "$db_version"

            # Iniciar el servicio
            echo -e "${BLUE}Iniciando servicio de MariaDB...${NC}"

            # Iniciar MariaDB en segundo plano
            echo -e "${BLUE}Iniciando MariaDB...${NC}"
            #"$BIN_DIR/mariadb/$db_version/bin/mysqld.exe" --defaults-file="$BIN_DIR/mariadb/$db_version/my.ini" --console > "$WEB_SERVER_DIR/logs/mariadb.log" 2>&1 &
            "$BIN_DIR/mariadb/$db_version/bin/mariadbd.exe" --install MariaDB --console > "$WEB_SERVER_DIR/logs/mariadb.log" 2>&1 &
            #"$BIN_DIR/mariadb/$db_version/bin/mariadbd.exe" --install MariaDB --defaults-file="$BIN_DIR/mariadb/$db_version/my.ini" --console > "$WEB_SERVER_DIR/logs/mariadb.log" 2>&1 &
            #"$BIN_DIR/mariadb/$db_version/bin/mysqld.exe" --install
            #"$BIN_DIR/mariadb/$db_version/bin/mysqld.exe" --install MariaDB --defaults-file="$BIN_DIR/mariadb/$db_version/my.ini" --datadir="$BIN_DIR/mariadb/$db_version/data"
            #sc stop MariaDB
            #sc delete MariaDB

            # Confirmar que arrancó correctamente
            sleep 2
            # if pgrep -f "mariadbd" > /dev/null; then
                # echo -e "${GREEN}MariaDB está en ejecución.${NC}"
            # else
                # echo -e "${RED}Error al iniciar MariaDB. Verifica el archivo de log: logs/mariadb.log.${NC}"
            # fi

            #add_to_path "$BIN_DIR/mariadb/$db_version/bin"
        fi
    fi

    echo -e "${GREEN}$INSTALLED_DB_ENGINE $db_version instalado correctamente.${NC}"
}

# Función para instalar phpMyAdmin
install_phpmyadmin() {
    echo -e "${BLUE}Instalando phpMyAdmin...${NC}"
    phpmyadmin_version=$(get_version "phpMyAdmin" $DEFAULT_PHPMYADMIN_VERSION)

    phpmyadmin_zip="phpMyAdmin-$phpmyadmin_version-all-languages.zip"
    phpmyadmin_url="https://files.phpmyadmin.net/phpMyAdmin/$phpmyadmin_version/$phpmyadmin_zip"

    download_file "$phpmyadmin_url" "$phpmyadmin_zip" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$phpmyadmin_zip" ]; then
        echo -e "${BLUE}Descomprimiendo phpMyAdmin...${NC}"
        # unzip -q "$DOWNLOADS_DIR/$phpmyadmin_zip" -d "$BIN_DIR"
        unzip -q "$DOWNLOADS_DIR/$phpmyadmin_zip" -d "$APPS_DIR"

        # Renombrar directorio
        # mv "$BIN_DIR/phpMyAdmin-$phpmyadmin_version-all-languages" "$BIN_DIR/phpmyadmin"
        mv "$APPS_DIR/phpMyAdmin-$phpmyadmin_version-all-languages" "$APPS_DIR/phpmyadmin"

        # Crear archivo de configuración
        cp "$APPS_DIR/phpmyadmin/config.sample.inc.php" "$APPS_DIR/phpmyadmin/config.inc.php"

        #
        config_inc="$APPS_DIR/phpmyadmin/config.inc.php"

        configure_phpmyadmin

        # Crear enlace simbólico en www para acceso web (solo si no existe)
        #if [ ! -L "$WEB_SERVER_DIR/phpmyadmin" ]; then
            #ln -s "$APPS_DIR/phpmyadmin" "$WEB_SERVER_DIR/phpmyadmin"
        #fi

        echo -e "${GREEN}phpMyAdmin $phpmyadmin_version instalado correctamente en $BIN_DIR/phpmyadmin${NC}"
        echo -e "${YELLOW}phpMyAdmin esta disponible para acceso a la web en: https://phpmyadmin.local${NC}"
    else
        echo -e "${RED}Error al descargar phpMyAdmin${NC}"
        return 1
    fi
}

# Función para configurar phpMyAdmin
configure_phpmyadmins() {
    echo -e "${BLUE}Configurando phpMyAdmin...${NC}"

    local config_inc="$APPS_DIR/phpmyadmin/config.inc.php"

    # Verificar si el archivo existe y es editable
    if [ ! -f "$config_inc" ]; then
        echo -e "${RED}Error: No se encontró el archivo config.inc.php${NC}"
        return 1
    fi

    if [ ! -w "$config_inc" ]; then
        echo -e "${RED}Error: No se tienen permisos para editar config.inc.php${NC}"
        return 1
    fi

    # Generar secreto Blowfish seguro (siempre lo hacemos, no solo para MySQL)
    #local blowfish_secret=$(openssl rand -base64 32 | tr -d '\n')
    #sed -i "s|\$cfg\['blowfish_secret'\] = '';|\$cfg\['blowfish_secret'\] = '${blowfish_secret}';|" "$config_inc"

    # Configurar blowfish secret
    sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = '$(openssl rand -base64 48 | tr -dc 'a-zA-Z0-9' | head -c 32)';/" "$BIN_DIR/phpmyadmin/config.inc.php"

    # Configuración común para todos los motores de base de datos
    sed -i "s|\$cfg\['Servers'\]\[\$i\]\['host'\] = .*|\$cfg\['Servers'\]\[\$i\]\['host'\] = '127.0.0.1';|" "$config_inc"
    sed -i "s|\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = .*|\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = 'cookie';|" "$config_inc"

    # Agregar configuraciones adicionales si no existen
    if ! grep -q "AllowNoPassword" "$config_inc"; then
        echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;" >> "$config_inc"
    fi

    if ! grep -q "hide_db" "$config_inc"; then
        echo "\$cfg['Servers'][\$i]['hide_db'] = '(information_schema|mysql|performance_schema|sys)';" >> "$config_inc"
    fi

    # Configuración específica para el servidor web
    if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
        local apache_conf="$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        if ! grep -q "phpmyadmin" "$apache_conf"; then
            echo "Alias /phpmyadmin \"$APPS_DIR/phpmyadmin\"" >> "$apache_conf"
            echo "<Directory \"$APPS_DIR/phpmyadmin\">" >> "$apache_conf"
            echo "    Options Indexes FollowSymLinks" >> "$apache_conf"
            echo "    AllowOverride All" >> "$apache_conf"
            echo "    Require all granted" >> "$apache_conf"
            echo "</Directory>" >> "$apache_conf"
        fi
    else # Nginx
        local nginx_conf="$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf"
        if ! grep -q "phpmyadmin" "$nginx_conf"; then
            echo "location /phpmyadmin {" >> "$nginx_conf"
            echo "    root $APPS_DIR;" >> "$nginx_conf"
            echo "    index index.php;" >> "$nginx_conf"
            echo "    location ~ \.php$ {" >> "$nginx_conf"
            echo "        include fastcgi_params;" >> "$nginx_conf"
            echo "        fastcgi_pass unix:/run/php/php-fpm.sock;" >> "$nginx_conf"
            echo "        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;" >> "$nginx_conf"
            echo "    }" >> "$nginx_conf"
            echo "}" >> "$nginx_conf"
        fi
    fi

    echo -e "${GREEN}phpMyAdmin configurado correctamente para $INSTALLED_DB_ENGINE y $INSTALLED_WEB_SERVER_ENGINE${NC}"
    echo -e "${YELLOW}Acceso: http://localhost/phpmyadmin${NC}"
}

# Función para configurar phpMyAdmin
configure_phpmyadmin() {
    echo -e "${BLUE}Configurando phpMyAdmin...${NC}"

    config_inc="$APPS_DIR/phpmyadmin/config.inc.php"

    if [ ! -f "$config_inc" ]; then
        echo -e "${RED}Archivo $config_inc no encontrado. Abortando configuración.${NC}"
        return 1
    fi

    # Configurar para MySQL/MariaDB
    if [ "$INSTALLED_DB_ENGINE" = "MySQL" ]; then
        sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = '.*';/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/" "$APPS_DIR/phpmyadmin/config.inc.php"
        sed -i "s/\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = '.*';/\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = 'cookie';/" "$APPS_DIR/phpmyadmin/config.inc.php"
    else
        # Generar secreto Blowfish seguro
        BLOWFISH_SECRET=$(openssl rand -base64 32 | tr -d '\n')
        sed -i "s|\(\$cfg\['blowfish_secret'\] *= *\).*|\1'$BLOWFISH_SECRET';|" "$config_inc"

        # Asegurarse de modificar los valores sin importar los espacios
        sed -i "s|\(\$cfg\['Servers'\]\[\$i\]\['host'\] *= *\).*|\1'127.0.0.1';|" "$config_inc"
        sed -i "s|\(\$cfg\['Servers'\]\[\$i\]\['auth_type'\] *= *\).*|\1'cookie';|" "$config_inc"
        sed -i "s|\(\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] *= *\).*|\1true;|" "$config_inc"

        # Agregar otros valores útiles si no existen
        grep -q "\$cfg\['Servers'\]\[\$i\]\['port'\]" "$config_inc" || echo "\$cfg['Servers'][\$i]['port'] = 3306;" >> "$config_inc"
        grep -q "\$cfg\['Servers'\]\[\$i\]\['hide_db'\]" "$config_inc" || echo "\$cfg['Servers'][\$i]['hide_db'] = '(information_schema|mysql|performance_schema|sys)';" >> "$config_inc"
        # Generar secreto Blowfish seguro
        # sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg\['blowfish_secret'\] = '$(openssl rand -base64 32)';/" "$config_inc"

        # Ajustes de conexión a base de datos
        # sed -i "s|\$cfg\['Servers'\]\[\$i\]\['host'\] = .*|\$cfg['Servers'][\$i]['host'] = '127.0.0.1';|" "$config_inc"
        # sed -i "s|\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = .*|\$cfg['Servers'][\$i]['auth_type'] = 'cookie';|" "$config_inc"

        # echo "\$cfg['Servers'][\$i]['port'] = 3306;" >> "$config_inc"
        # echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = true;" >> "$config_inc"
        # echo "\$cfg['Servers'][\$i]['hide_db'] = '(information_schema|mysql|performance_schema|sys)';" >> "$config_inc"
    fi

    # Configurar para Apache o Nginx
    if [ "$INSTALLED_WEB_SERVER_ENGINE" = "Apache" ]; then
        echo "Alias /phpmyadmin \"$APPS_DIR/phpmyadmin\"" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        echo "<Directory \"$APPS_DIR/phpmyadmin\">" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        echo "    Options Indexes FollowSymLinks" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        echo "    AllowOverride All" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        echo "    Require all granted" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
        echo "</Directory>" >> "$BIN_DIR/apache/$DEFAULT_APACHE_VERSION/conf/httpd.conf"
    else
        # Para Nginx, agregar configuración
        echo "location /phpmyadmin {" >> "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf"
        echo "    root $BIN_DIR;" >> "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf"
        echo "    index index.php;" >> "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf"
        echo "}" >> "$BIN_DIR/nginx/$DEFAULT_NGINX_VERSION/conf/nginx.conf"
    fi

    echo -e "${GREEN}phpMyAdmin configurado para $INSTALLED_DB_ENGINE y $INSTALLED_WEB_SERVER_ENGINE${NC}"
}

# Función para instalar Apache
install_apache() {
    echo -e "${BLUE}Instalando Apache...${NC}"
    apache_version=$(get_version "Apache" $DEFAULT_APACHE_VERSION)
    apache_zip="httpd-${apache_version}-250207-win64-VS17.zip"
    apache_url="https://www.apachelounge.com/download/VS17/binaries/$apache_zip"
    # https://www.apachelounge.com/download/VS17/binaries/httpd-2.4.63-250207-win64-VS17.zip

    download_file "$apache_url" "$apache_zip" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$apache_zip" ]; then
        echo -e "${BLUE}Descomprimiendo Apache...${NC}"
        # Extraer en un directorio temporal primero
        APACHE_TEMP_DIR="$TEMP_DIR/temp_apache"
        mkdir -p "$APACHE_TEMP_DIR"
        unzip -q "$DOWNLOADS_DIR/$apache_zip" -d "$APACHE_TEMP_DIR"

        # Verificar si existe el directorio Apache24
        if [ -d "$APACHE_TEMP_DIR/Apache24" ]; then
            # Mover el contenido a la ubicación final
            mkdir -p "$BIN_DIR/apache/$apache_version"

            # Verificar si el directorio de destino ya existe
            if [ -d "$BIN_DIR/apache/$apache_version" ]; then
                echo -e "${YELLOW}Advertencia: El directorio $BIN_DIR/apache/$apache_version ya existe.${NC}"
                read -p "¿Deseas sobrescribirlo? (s/n): " overwrite_choice
                case "$overwrite_choice" in
                    [sS])
                        echo -e "${BLUE}Eliminando el directorio existente...${NC}"
                        rm -rf "$BIN_DIR/apache/$apache_version"
                        mkdir -p "$BIN_DIR/apache/$apache_version"
                        ;;
                    [nN])
                        echo -e "${RED}Instalación cancelada por el usuario.${NC}"
                        rm -rf "$APACHE_TEMP_DIR"
                        return 1
                        ;;
                    *)
                        echo -e "${RED}Opción inválida. Instalación cancelada.${NC}"
                        rm -rf "$APACHE_TEMP_DIR"
                        return 1
                        ;;
                esac
            else
                mkdir -p "$BIN_DIR/apache/$apache_version"
            fi

            # Mover los archivos descomprimidos
            mv "$APACHE_TEMP_DIR/Apache24/"* "$BIN_DIR/apache/$apache_version/"

            # Agregar Apache al PATH
            add_to_path "$BIN_DIR/apache/$apache_version/bin"

            # Configuración crítica de Apache
            APACHE_DIR_WIN=$(cygpath -w "$BIN_DIR/apache/$apache_version" | sed 's/\\/\\\\/g')

            #
            httpd_conf_file="$BIN_DIR/apache/$apache_version/conf/httpd.conf"

            #
            generate_custom_httpd_conf

            # Configurar httpd.conf
            sed -i "s|^Define SRVROOT .*|Define SRVROOT \"$APACHE_DIR_WIN\"|" "$httpd_conf_file"
            sed -i "s|^ServerRoot .*|ServerRoot \"$APACHE_DIR_WIN\"|" "$httpd_conf_file"
            sed -i "s|^DocumentRoot .*|DocumentRoot \"$(echo "$WEB_SERVER_DIR" | sed 's/\//\\\\/g')\\\\www\"|" "$httpd_conf_file"
            sed -i "/^DocumentRoot \"$(echo "$WEB_SERVER_DIR" | sed 's/\//\\\\/g')\\\\www\"$/{n;s|^<Directory \".*|<Directory \"$(echo "$WEB_SERVER_DIR" | sed 's/\//\\\\/g')\\\\www\">|}" "$httpd_conf_file"
            sed -i "s|^ErrorLog \"logs/error.log\"$|ErrorLog \"$(echo "$WEB_SERVER_DIR" | sed 's/\//\\\\/g')\\\\logs\\\\apache_error.log\"|" "$httpd_conf_file"
            sed -i "s|^LogLevel warn$|LogLevel error|" "$httpd_conf_file"
            sed -i "/^#ServerName www.example.com:80/a ServerName webServer" "$httpd_conf_file"

            # Descomentar módulos necesarios
            modules_to_enable=(
                "headers_module modules/mod_headers.so"
                "rewrite_module modules/mod_rewrite.so"
                "ssl_module modules/mod_ssl.so"
                # "socache_memcache_module modules/mod_socache_memcache.so"
                # "socache_redis_module modules/mod_socache_redis.so"
                "socache_shmcb_module modules/mod_socache_shmcb.so"
                "version_module modules/mod_version.so"
                "access_compat_module modules/mod_access_compat.so"
            )

            for module in "${modules_to_enable[@]}"; do
                sed -i "s|^#LoadModule $module|LoadModule $module|" "$BIN_DIR/apache/$apache_version/conf/httpd.conf"
            done

            echo -e "${BLUE}Módulos descomentados correctamente en httpd.conf.${NC}"

            # Configurar PHP
            if [ -n "$INSTALLED_PHP_VERSION" ]; then
                #
                generate_mod_php_conf "$INSTALLED_PHP_VERSION"

                echo "# Configuración" >> "$httpd_conf_file"
                echo "IncludeOptional \"$ETC_DIR/apache2/sites-enabled/*.conf\"" >> "$httpd_conf_file"
                echo "IncludeOptional \"$ETC_DIR/apache2/alias/*.conf\"" >> "$httpd_conf_file"
                echo "Include \"$ETC_DIR/apache2/httpd-ssl.conf\"" >> "$httpd_conf_file"
                echo "Include \"$ETC_DIR/apache2/mod_php.conf\"" >> "$httpd_conf_file"

                # Crear el archivo con la configuración SSL
                generate_httpd_ssl_conf

                # Crear el archivo host predeterminado
                #configure_virtual_host unattended=true

                generate_apache_default_virtualhost
                generate_apache_phpmyadmin_virtualhost
                generate_ssl_for_default_virtualhost

                # Asegurar que index.php esté en DirectoryIndex
                sed -i "s|^[[:space:]]*DirectoryIndex .*|    DirectoryIndex index.php index.html|" "$httpd_conf_file"
            fi

            # Verificar si el servicio Apache2.4 está instalado
            if sc query Apache2.4 | grep -q "Apache2.4"; then
                echo -e "${GREEN}El servicio Apache2.4 ya está instalado.${NC}"

                # Intentar iniciar el servicio si no está corriendo
                if sc query Apache2.4 | grep -q "RUNNING"; then
                    echo -e "${GREEN}El servicio Apache2.4 ya se está ejecutando.${NC}"
                else
                    echo -e "${BLUE}Iniciando el servicio Apache2.4...${NC}"
                    net start Apache2.4
                    if [ $? -ne 0 ]; then
                        echo -e "${RED}Error: No se pudo iniciar el servicio Apache2.4.${NC}"
                        return 1
                    else
                        echo -e "${GREEN}El servicio Apache2.4 se inició correctamente.${NC}"
                    fi
                fi

            else
                echo -e "${BLUE}Instalando el servicio Apache2.4...${NC}"
                "$BIN_DIR/apache/$apache_version/bin/httpd.exe" -k install -n "Apache2.4" -d "$BIN_DIR/apache/$apache_version" -e
                if [ $? -ne 0 ]; then
                    echo -e "${RED}Error: Falló la instalación del servicio Apache2.4.${NC}"
                    return 1
                fi

                echo -e "${BLUE}Iniciando el servicio Apache2.4...${NC}"
                net start Apache2.4
                if [ $? -ne 0 ]; then
                    echo -e "${RED}Error: No se pudo iniciar el servicio Apache2.4.${NC}"
                    return 1
                else
                    echo -e "${GREEN}El servicio Apache2.4 se instaló e inició correctamente.${NC}"
                fi
            fi

            # Mostrar la versión de Apache
            "$BIN_DIR/apache/$apache_version/bin/httpd.exe" -v

            # Guardar versión instalada
            update_env_var "INSTALLED_WEB_SERVER_ENGINE" "Apache"
            update_env_var "INSTALLED_WEB_SERVER_ENGINE_VERSION" "$apache_version"
            update_env_var "INSTALLED_WEB_SERVER_ENGINE_DIR" "$BIN_DIR/apache/$apache_version/"
        else
            echo -e "${RED}Error: No se encontró el directorio Apache24 en el archivo descargado.${NC}"
            return 1
        fi

        # Limpiar directorio temporal
        rm -rf "$APACHE_TEMP_DIR"
    else
        echo -e "${RED}Error al descargar Apache.${NC}"
        return 1
    fi

    # Borrar
    # Instalar Nginx en segundo plano si no está instalado
    # if [ ! -f "$CONFIG_DIR/nginx_version.conf" ]; then
        # echo -e "${YELLOW}Instalando Nginx para futuras configuraciones (Vhots/SSL)...${NC}"
        # install_nginx unattended=true
    # fi

    echo -e "${GREEN}Apache $apache_version instalado correctamente en $BIN_DIR/apache/$apache_version${NC}"
}

#
generate_custom_httpd_conf() {
    echo -e "${GREEN}Archivo httpd.conf configurado correctamente.${NC}"
}

# Función para instalar Nginx
install_nginx() {
    echo -e "${BLUE}Instalando Nginx...${NC}"

    # Llamamos a la función para procesar los argumentos
    local unattended=$(parse_arguments "$@")

    echo "Instalar Nginx con unattended=$unattended"

    if [[ "$unattended" == true ]]; then
        nginx_version="${DEFAULT_NGINX_VERSION}"
        echo "Modo unattended activado. Usando versión por defecto desde webServer.env: $NGINX_VERSION"
    else
        read -p "Ingresa la versión de Nginx a instalar (por defecto: ${DEFAULT_NGINX_VERSION}): " NGINX_VERSION
        nginx_version=$(get_version "Nginx" $DEFAULT_NGINX_VERSION)
    fi

    nginx_zip="nginx-$nginx_version.zip"
    nginx_url="https://nginx.org/download/nginx-$nginx_version.zip"
    # https://nginx.org/download/nginx-1.27.5.zip

    download_file "$nginx_url" "$nginx_zip" "$DOWNLOADS_DIR"

    if [ -f "$DOWNLOADS_DIR/$nginx_zip" ]; then
        unzip -q "$DOWNLOADS_DIR/$nginx_zip" -d "$BIN_DIR/nginx"
        mv "$BIN_DIR/nginx/nginx-$nginx_version" "$BIN_DIR/nginx/$nginx_version"
        add_to_path "$BIN_DIR/nginx/$nginx_version"

        # Crear estructura de configuración
        mkdir -p "$ETC_DIR/nginx/sites-enabled"
        mkdir -p "$ETC_DIR/nginx/alias"

        # Crear archivo de configuración de Nginx
        generate_default_nginx_conf "$BIN_DIR/nginx/$nginx_version/conf/nginx.conf"

        # Crear archivo de configuración de Nginx
        generate_default_nginx_vhosts

        # Crear archivo de prueba
        echo "<?php phpinfo(); ?>" > "$WEB_SERVER_DIR/www/phpinfo.php"

        echo -e "${GREEN}Archivo de prueba PHP creado en http://localhost/info.php${NC}"
        echo -e "${GREEN}phpMyAdmin disponible en http://localhost/phpmyadmin${NC}"

        # Validar la configuración antes de iniciar
        echo -e "${BLUE}Validando configuración de Nginx...${NC}"
        "$BIN_DIR/nginx/$nginx_version/nginx.exe" -t -p "$BIN_DIR/nginx/$nginx_version"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Configuración válida. Iniciando Nginx...${NC}"
            start "$BIN_DIR/nginx/$nginx_version/nginx.exe"
            start_php_cgi
        else
            echo -e "${RED}Error en la configuración de Nginx. No se iniciará.${NC}"
            return 1
        fi

        # Iniciar Nginx
        echo -e "${BLUE}Iniciando Nginx...${NC}"
        start "$BIN_DIR/nginx/$nginx_version/nginx.exe"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Nginx iniciado correctamente.${NC}"
        else
            echo -e "${YELLOW}Advertencia: No se pudo iniciar Nginx. Verifica la configuración y los logs.${NC}"
        fi

        # Guardar versión instalada
        update_env_var "INSTALLED_WEB_SERVER_ENGINE" "Nginx"
        update_env_var "INSTALLED_WEB_SERVER_ENGINE_VERSION" "$nginx_version"
        update_env_var "INSTALLED_WEB_SERVER_ENGINE_DIR" "$BIN_DIR/nginx/$nginx_version/"

        update_env_var "INSTALLED_NGINX_VERSION" "$nginx_version"
        update_env_var "INSTALLED_NGINX_DIR" "$BIN_DIR/nginx/$nginx_version/"
    else
        echo -e "${RED}Error al descargar Nginx.${NC}"
        return 1
    fi

    # Borrar
    # Instalar Apache en segundo plano si no está instalado
    # if [ ! -f "$CONFIG_DIR/apache_version.conf" ]; then
        # echo -e "${YELLOW}Instalando Apache en segundo plano para futuras configuraciones...${NC}"
        # (install_apache --silent) >/dev/null 2>&1
    # fi

    echo -e "${GREEN}Nginx $nginx_version instalado correctamente.${NC}"
    log "Nginx $nginx_version instalado correctamente."
}

#
uninstall_nginx() {
    echo -e "${YELLOW}Desinstalando Nginx...${NC}"

    # Borrar
    # if [ -z "$INSTALLED_NGINX_VERSION" ]; then
        # if [ -f "$CONFIG_DIR/nginx_version.conf" ]; then
            # INSTALLED_NGINX_VERSION=$(cat "$CONFIG_DIR/nginx_version.conf")
        # fi
    # fi

    local nginx_path="$BIN_DIR/nginx/$INSTALLED_NGINX_VERSION"

    if [ -d "$nginx_path" ]; then
        echo -e "${BLUE}Deteniendo procesos de Nginx...${NC}"
        taskkill //F //IM nginx.exe > /dev/null 2>&1

        echo -e "${BLUE}Eliminando archivos de Nginx...${NC}"
        rm -rf "$nginx_path"
    fi

    echo -e "${BLUE}Eliminando configuración y sitios...${NC}"
    rm -rf "$ETC_DIR/nginx"

    echo -e "${GREEN}Nginx desinstalado correctamente.${NC}"
    log "Nginx $INSTALLED_NGINX_VERSION desinstalado."
}

#
start_php_cgi() {
    # Borrar
    # if [ -z "$INSTALLED_PHP_VERSION" ]; then
        # if [ -f "$CONFIG_DIR/php_version.conf" ]; then
            # INSTALLED_PHP_VERSION=$(cat "$CONFIG_DIR/php_version.conf")
        # else
            # echo -e "${RED}PHP no está instalado o no se detectó versión.${NC}"
            # return 1
        # fi
    # fi

    local php_cgi="$BIN_DIR/php/$INSTALLED_PHP_VERSION/php-cgi.exe"

    if [ ! -f "$php_cgi" ]; then
        echo -e "${RED}No se encontró php-cgi.exe en $php_cgi${NC}"
        return 1
    fi

    echo -e "${BLUE}Iniciando PHP CGI...${NC}"
    start "$php_cgi" -b 127.0.0.1:9000

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PHP CGI iniciado correctamente en el puerto 127.0.0.1:9000${NC}"
    else
        echo -e "${RED}Error al iniciar PHP CGI.${NC}"
    fi
}

# Función para procesar los parámetros de entrada
parse_arguments() {
    local unattended=false

    # Procesamos los parámetros de entrada
    for arg in "$@"; do
        case $arg in
            unattended=*)
                unattended="${arg#*=}"
                ;;
        esac
    done

    echo "$unattended"
}

# Función para instalar todos los componentes
install_all() {
    install_git
    install_php
    INSTALLED_PHP_VERSION=$(get_version "PHP" $DEFAULT_PHP_VERSION)
    install_python
    install_node
    install_database
    install_phpmyadmin
    install_composer
    configure_phpmyadmin
    configure_integration
    configure_virtual_host  # Nueva función añadida
    # create_startup_scripts

    # Mostrar resumen al final
    show_installation_summary
}

# Función para registrar logs con timestamp
log() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    # mkdir -p "$WEB_SERVER_DIR/logs"
    echo "[$timestamp] $message" >> "$WEB_SERVER_DIR/logs/setup.log"
    echo -e "${YELLOW}$message.${NC}"
}

# Función mejorada para descargar archivos con fallback
download_file_with_fallback() {
    local url=$1
    local filename=$2
    local dest_dir=$3
    local filepath="$dest_dir/$filename"

    mkdir -p "$dest_dir"

    if [ -f "$filepath" ]; then
        log "Archivo $filename ya existe. Omitiendo descarga."
        return 0
    fi

    log "Intentando descargar $filename desde $url..."

    if command -v wget &> /dev/null; then
        wget -q --show-progress -O "$filepath" "$url" && log "Descarga completada con wget." && return 0
    fi

    if command -v curl &> /dev/null; then
        curl -L -o "$filepath" "$url" && log "Descarga completada con curl." && return 0
    fi

    if command -v choco &> /dev/null; then
        choco install -y "$filename"
        log "Intento de descarga con Chocolatey para $filename"
        return 0
    fi

    log "ERROR: No se pudo descargar $filename desde $url"
    return 1
}

# Función para instalar Redis y Memcached
install_cache_services() {
    log "Instalando Redis y Memcached..."

    choco install -y redis-64 memcached

    # Agregar extensiones a php.ini
    ini_file="$BIN_DIR/php/$INSTALLED_PHP_VERSION/php.ini"
    for ext in redis memcached; do
        if ! grep -q "extension=$ext" "$ini_file"; then
            echo "extension=$ext" >> "$ini_file"
            log "Extensión $ext agregada a php.ini"
        fi
    done

    log "Redis y Memcached instalados y configurados correctamente."
}

# Función para instalar imagick y otras extensiones útiles
install_php_extensions() {
    log "Instalando extensiones PHP útiles (imagick, intl, soap)..."
    ini_file="$BIN_DIR/php/$INSTALLED_PHP_VERSION/php.ini"

    for ext in imagick intl soap; do
        dll="php_$ext.dll"
        if [ ! -f "$BIN_DIR/php/$INSTALLED_PHP_VERSION/ext/$dll" ]; then
            log "Advertencia: No se encontró $dll en ext/. Instálalo manualmente si es necesario."
        else
            if ! grep -q "extension=$ext" "$ini_file"; then
                echo "extension=$ext" >> "$ini_file"
                log "Extensión $ext agregada a php.ini"
            fi
        fi
    done
}

# Función para crear backup del entorno
backup_environment() {
    log "Generando backup del entorno..."
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_dir="$WEB_SERVER_DIR/backups"
    mkdir -p "$backup_dir"

    backup_file="$backup_dir/webServer_backup_$timestamp.zip"

    powershell -Command "Compress-Archive -Path '$WEB_SERVER_DIR\*' -DestinationPath '$backup_file'"

    log "Backup generado: $backup_file"
}

# Función para desinstalar y limpiar entorno
uninstall_cleanup() {
    read -p "¿Estás seguro de que deseas desinstalar todo el entorno? (s/N): " confirm
    if [[ "$confirm" =~ ^[SsYy]$ ]]; then
        log "Iniciando proceso de limpieza..."

        net stop Apache &> /dev/null
        taskkill /IM nginx.exe /F &> /dev/null
        taskkill /IM mysqld.exe /F &> /dev/null
        taskkill /IM redis-server.exe /F &> /dev/null
        taskkill /IM memcached.exe /F &> /dev/null

        rm -rf "$WEB_SERVER_DIR/bin" "$WEB_SERVER_DIR/tmp" "$WEB_SERVER_DIR/config" "$WEB_SERVER_DIR/www" "$WEB_SERVER_DIR/downloads"
        log "Carpetas del entorno eliminadas."

        echo -e "${GREEN}Entorno completamente desinstalado.${NC}"
    else
        log "Limpieza cancelada por el usuario."
    fi
}

#
generate_default_nginx_conf() {
    local nginx_conf_path=$1
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_path="${nginx_conf_path}.backup_$timestamp"

    echo -e "${YELLOW}Reemplazando nginx.conf en: $nginx_conf_path.${NC}"

    if [[ -f "$nginx_conf_path" ]]; then
        cp "$nginx_conf_path" "$backup_path"
        echo -e "${CYAN}Backup creado en: $backup_path.${NC}"
    fi

    cat > "$nginx_conf_path" <<EOF
# Especifica el usuario bajo el que se ejecutarán los procesos worker de Nginx.
# user nginx;

worker_processes  auto;

#
# Bloque de configuración de eventos
#
events {
    worker_connections 1024; # Número máximo de conexiones simultáneas por worker
}

# Define la ubicación del archivo de log de errores.
error_log   $LOGS_DIR/nginx.error.log warn;

# Archivo PID para el proceso maestro.
pid $BIN_DIR/nginx/$INSTALLED_NGINX_VERSION/logs/nginx.pid;

#
# Bloque de configuración HTTP
#
http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    # Configuración de logging
    access_log  $LOGS_DIR/nginx.access.log main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #
    # Configuración Gzip
    #
    gzip              on;
    gzip_vary         on;
    gzip_proxied      any;
    gzip_comp_level   6;
    gzip_buffers      16 8k;
    gzip_http_version 1.1;
    gzip_types        text/plain text/css application/json application/javascript application/xml application/xhtml+xml application/rss+xml font/ttf font/otf font/woff font/woff2 image/svg+xml;

    #
    # Configuración de caché para archivos estáticos
    #
    # location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|otf)\$ {
    #     expires         30d;
    #     add_header      Cache-Control public;
    #     access_log      off;
    #     log_not_found   off;
    # }

    #
    # Seguridad: bloquear archivos sensibles
    #
    # location ~ /\.ht {
    #     deny all;
    # }

    # location ~ /\.git {
    #     deny all;
    # }

    #
    # Otras configuraciones
    #
    client_max_body_size 2000M;
    server_names_hash_bucket_size 64;

    # Configuración de SSL global
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    resolver            8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout    5s;
    # ssl_trusted_certificate /path/to/your/ca_certificate.crt;

    # Incluir configuraciones de sitios
    include $WEB_SERVER_DIR/etc/nginx/sites-enabled/*.conf;
}
EOF

    echo -e "${GREEN}Archivo nginx.conf generado exitosamente.${NC}"
}

# Función para crear el archivo httpd-ssl.conf para SSL
generate_httpd_ssl_conf() {
    local httpd_ssl_path="$ETC_DIR/apache2/httpd-ssl.conf"

    rm -f "$httpd_ssl_path"

    cat > "$httpd_ssl_path" <<EOF
Listen 443

SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4
SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4

SSLHonorCipherOrder on

SSLProtocol all -SSLv3
SSLProxyProtocol all -SSLv3

SSLSessionCache "shmcb:logs/ssl_scache(512000)"
SSLSessionCacheTimeout  300
EOF
    log "Archivo httpd-ssl.conf creado para PHP en $httpd_ssl_path."
}

# Función para crear archivo mod_php.conf para PHP
generate_mod_php_conf() {
    local php_version=$1
    local mod_php_path="$ETC_DIR/apache2/mod_php.conf"

    if [ -f "$mod_php_path" ]; then
        log "El archivo mod_php.conf ya existe."
        return
    fi

    cat > "$mod_php_path" <<EOF
# Configuración PHP
LoadModule php_module "$BIN_DIR/php/$php_version/php8apache2_4.dll"
PHPIniDir "$BIN_DIR/php/$php_version"
AddHandler application/x-httpd-php .php
EOF
    log "Archivo mod_php.conf creado para PHP en $mod_php_path."
}

# Función para crear archivo my.ini para MariaDB
create_mariadb_ini() {
    local db_version=$1
    ini_path="$BIN_DIR/mariadb/$db_version/my.ini"

    if [ -f "$ini_path" ]; then
        log "El archivo my.ini ya existe."
        return
    fi

    cat > "$ini_path" <<EOF
[mysqld]
port=3306
basedir=$BIN_DIR/mariadb/$db_version
datadir=$BIN_DIR/mariadb/$db_version/data
max_allowed_packet=64M
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci
default-storage-engine=InnoDB
sql-mode="STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION"
skip-grant-tables

[client]
port=3306
EOF

    log "Archivo my.ini creado para MariaDB en $ini_path"
}

# Menú principal
while true; do
    show_menu
    read -p "Selecciona una opción (1-20): " choice

    case $choice in
        1) install_git ;;
        2) install_php ;;
        3) install_python ;;
        4) install_node ;;
        5) install_database ;;
        6) install_phpmyadmin ;;
        7) install_apache ;;
        8) install_nginx ;;
        9) install_composer ;;
        10) install_all ;;
        11) configure_integration ;;
        12) create_startup_scripts ;;
        13) configure_virtual_host ;;
        14) configure_ssl ;;
        15) show_installation_summary ;;
        16) install_cache_services ;;
        17) install_php_extensions ;;
        18) backup_environment ;;
        19) uninstall_cleanup ;;
        20)
            echo -e "${GREEN}Saliendo del script. ¡Hasta luego!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida. Por favor, selecciona una opción del 1 al 13.${NC}"
            sleep 2
            ;;
    esac

    read -p "Presiona Enter para continuar..."
done
