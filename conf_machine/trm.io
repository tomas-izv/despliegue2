server {
  listen 80;
  listen [::]:80;
  root /var/www/tomasWeb/html/static-website-example/index.html;
  index index.html index.htm index.nginx-debian.html;
  server_name tomasWeb;
  location / {
  try_files $uri $uri/ =404;
  }
}

