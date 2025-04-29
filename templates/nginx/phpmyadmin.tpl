server {
    listen 80;
    server_name phpmyadmin.local;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    http2  on;
    server_name phpmyadmin.local;

    ssl_certificate     C:/webServer/etc/ssl/phpmyadmin.local.crt;
    ssl_certificate_key C:/webServer/etc/ssl/phpmyadmin.local.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Content-Security-Policy "default-src 'self' https: data: blob: 'unsafe-inline' 'unsafe-eval';";

    root C:/webServer/etc/apps/phpmyadmin;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    access_log C:/webServer/logs/phpmyadmin-access.log;
    error_log  C:/webServer/logs/phpmyadmin-error.log;

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }

    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|ttf|woff|woff2|eot|otf|map)$ {
        access_log off;
        expires 1y;
        add_header Cache-Control "public";
    }

    location ~ (config\.inc\.php|setup/|libraries/|templates/|sql|doc/|test/) {
        deny all;
        return 403;
    }

    charset utf-8;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    location ~ /\.ht {
        deny all;
        return 403;
    }

    location ~ /(config|temp|tmp)\.(inc|php)$ {
        deny all;
        return 403;
    }
}
