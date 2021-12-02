server {
    listen 80;
    root /var/www/html/moodle;
    index index.php index.html index.htm;
#    server_name yourdomain.com www.yourdomain.com;
    server_name {{ ansible_facts.eth0.ipv4.address }};

    location / {
        try_files $uri $uri/ =404;
    }

    location /dataroot/ {
        internal;
        alias /var/www/html/moodledata/;
    }

    location ~ [^/]\.php(/|$) {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
