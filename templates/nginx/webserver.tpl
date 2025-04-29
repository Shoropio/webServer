server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name webserver.local;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl default_server;
    listen [::]:443 default_server;
    http2  on;
    server_name webserver.local;

    ssl_certificate     C:/webServer/etc/ssl/webserver.local.crt;
    ssl_certificate_key C:/webServer/etc/ssl/webserver.local.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    root C:/webServer/www;
    index index.php index.html index.htm;

    access_log C:/webServer/logs/webserver-access.log;
    error_log  C:/webServer/logs/webserver-error.log;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $realpath_root$fastcgi_script_name;
        include        fastcgi_params;
    }

    include $WEB_SERVER_DIR/etc/nginx/conf/alias/*.conf;

    location ~ /\. {
        deny all;
    }
}
