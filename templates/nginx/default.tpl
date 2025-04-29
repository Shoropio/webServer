server {
    listen 80;
    server_name {{DOMAIN}} www.{{DOMAIN}};

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    http2  on;
    server_name {{DOMAIN}} www.{{DOMAIN}};

    ssl_certificate     C:/webServer/etc/ssl/{{CERT}}.crt;
    ssl_certificate_key C:/webServer/etc/ssl/{{CERT}}.key;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    root {{ROOT}};
    index {{INDEX}};

    access_log C:/webServer/logs/{{DOMAIN}}-access.log;
    error_log  C:/webServer/logs/{{DOMAIN}}-error.log;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include        fastcgi_params;

        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 256k;
        fastcgi_busy_buffers_size 256k;
    }

    location ~* \.(jpg|jpeg|gif|png|css|js|ico|webp|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, no-transform";
        try_files $uri =404;
    }

    location ~ /\.(env|git|svn|htaccess|htpasswd) {
        deny all;
        return 403;
    }

    location ~ /\.env {
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
