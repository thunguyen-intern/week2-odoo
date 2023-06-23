#!/bin/bash
#--------------------------------------------------
# Install Nginx
#--------------------------------------------------
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
DEB_DISTRO=$(lsb_release -cs)
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu/ $DEB_DISTRO nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu/ $DEB_DISTRO nginx" | sudo tee -a /etc/apt/sources.list.d/nginx.listecho -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx
sudo apt-get update
sudo apt-get install nginx
#sudo touch /etc/nginx/conf.d/${ODOO_CONFIG}.conf
cat <<EOF > ~/odoo.conf
upstream odoo {
    server 127.0.0.1:8069;
}
upstream odoochat {
    server 127.0.0.1:8072;
}
server {
    listen 80;
    server_name localhost;
    proxy_read_timeout 720s;
    proxy_connect_timeout 720s;
    proxy_send_timeout 720s;
    # Add Headers for odoo proxy mode
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Real-IP $remote_addr;
    # log
    access_log /var/log/nginx/odoo.access.log;
    error_log /var/log/nginx/odoo.error.log;
    # Redirect longpoll requests to odoo longpolling port
    location /longpolling {
        proxy_pass http://odoochat;
    }
    # Redirect requests to odoo backend server
    location / {
        # proxy_redirect off;
        proxy_pass http://odoo;
    }
    # common gzip
    gzip_types text/css text/scss text/plain text/xml application/xml application/json application/javascript;
    gzip on;
}
EOF
sudo mv ~/odoo.conf /etc/nginx/conf.d/
#sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/odoo
sudo rm /etc/nginx/conf.d/default.conf
sudo systemctl daemon-reload
sudo systemctl start nginx
sudo systemctl enable nginx
#sudo su root -c "printf 'proxy_mode = True\n' >> /etc/${OE_CONFIG}.conf"
echo "Done! The Nginx server is up and running. Configuration can be found at /etc/nginx/conf.d/odoo.conf"

echo -e "* Starting Odoo Service"
sudo systemctl start nginx
sudo systemctl enable nginx
echo "-----------------------------------------------------------"
echo "Done! The Odoo server is up and running. Specifications:"
echo "Port: $ODOO_PORT"
echo "User service: $ODOO_USER"
echo "User PostgreSQL: $ODOO_USER"
echo "Code location: $ODOO_USER"
echo "Addons folder: $ODOO_USER/$ODOO_CONFIG/addons/"
echo "Password superadmin (database): $ODOO_SUPERADMIN"
echo "Start Odoo service: sudo systemctl start $ODOO_CONFIG"
echo "Stop Odoo service: sudo systemctl stop $ODOO_CONFIG"
echo "Restart Odoo service: sudo systemctl restart $ODOO_CONFIG"
echo "-----------------------------------------------------------"
