#!/bin/bash
################################################################################
# --------------------- Install Odoo15 on Debian 11 ----------------------------
# Prerequisites:
# A Debian 11
# Access to the root user account
################################################################################

ODOO_USER="odoo"
ODOO_HOME="/$ODOO_USER"
ODOO_HOME_EXIT="/$ODOO_USER/$ODOO_USER"
ODOO_PORT=8069
ODOO_VERSION=15.0
ODOO_CONFIG="${ODOO_USER}"
ODOO_SUPERADMIN="admin"

#WKHTMLTOX=https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb

#--------------------------------------------------
# Update Server
#--------------------------------------------------
echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server ----"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get install postgresql -y
sudo systemctl start postgresql
sudo systemctl enable postgresql

#echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
#sudo su - postgres -c "createuser -s $ODOO_USER" 2> /dev/null || true
#sudo su - postgres -c "createdb odoo"
#sudo -u postgres psql -c "ALTER USER odoo WITH SUPERUSER;"
#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------

echo -e "\n--- Installing Python 3 + pip3 --"
#sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt1-dev -y
#sudo apt-get install libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less gdebi -y
sudo apt-get python3 python3-pip python-dev python3-dev libxml2-dev libpq-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libjpeg-dev libblas-dev libatlas-base-dev postgresql-devel
sudo apt-get install --reinstall libpq-dev
sudo apt-get install postgresql-server postgresql-contrib postgresql-libs

echo -e "\n---- Installing nodeJS NPM and rtlcss for LTR support ----"
sudo apt-get install nodejs npm -y
#sudo npm install -g rtlcss
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less

#--------------------------------------------------
# Install Wkhtmltopdf
#--------------------------------------------------
echo -e "\n---- Install wkhtmltox ----"
sudo apt-get install wkhtmltopdf -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo -i
su - postgres -c "createuser -s $ODOO_USER"
su - postgres -c "createdb odoo"
sudo -u postgres psql -c "ALTER USER odoo WITH SUPERUSER;"

echo -e "\n---- Create ODOO system user ----"
useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

#--------------------------------------------------
# Install ODOO
#--------------------------------------------------
echo -e "\n==== Installing ODOO Server ===="
#sudo git clone --depth 1 --branch $ODOO_VERSION https://www.github.com/odoo/odoo $ODOO_HOME_EXIT/
sudo su - odoo
git clone https://www.github.com/odoo/odoo --depth 1 --branch 15.0 /opt/odoo/odoo
pip install --upgrade pip
pip install wheel setuptools
pip3 install -r /opt/odoo/odoo/requirements.txt
echo -e "* Create config file"
sudo touch /etc/${ODOO_CONFIG}.conf
sudo su root -c "printf '[options] \n; This is the password that allows database operations:\n' > /etc/${ODOO_CONFIG}.conf"

sudo su root -c "printf 'admin_passwd = ${ODOO_SUPERADMIN}\n' >> /etc/${ODOO_CONFIG}.conf"
sudo su root -c "printf 'http_port = ${ODOO_PORT}\n' >> /etc/${ODOO_CONFIG}.conf"
sudo su root -c "printf 'xmlrpc_interface = 0.0.0.0\n' >> /etc/${ODOO_CONFIG}.conf"
sudo su root -c "printf 'proxy_mode = True\n' >> /etc/${ODOO_CONFIG}.conf"
sudo su root -c "printf 'addons_path = /opt/odoo/odoo/addons\n' >> /etc/${ODOO_CONFIG}.conf"
sudo su root -c "printf 'logfile = /var/log/${ODOO_USER}/${ODOO_CONFIG}.log\n' >> /etc/${ODOO_CONFIG}.conf"

sudo chown $ODOO_USER:$ODOO_USER /etc/${ODOO_CONFIG}.conf
sudo chmod 640 /etc/${ODOO_CONFIG}.conf

echo -e "* Create init file"
sudo touch /etc/systemd/system/${ODOO_CONFIG}.service

sudo su root -c "printf '[Unit]\n' > /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'Description=Odoo \n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'Requires=postgresql.service\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'After=network.target postgresql.service\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf '[Service]\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'Type=simple\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'User=$ODOO_USER\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'ExecStart=/opt/odoo/odoo/odoo-bin -c /etc/${ODOO_CONFIG}.conf\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf '[Install]\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"
sudo su root -c "printf 'WantedBy=multi-user.target\n' >> /etc/systemd/system/${ODOO_CONFIG}.service"

sudo chmod 755 /etc/systemd/system/${ODOO_CONFIG}.service
sudo chown root: /etc/systemd/system/${ODOO_CONFIG}.service

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$ODOO_USER
sudo chown $ODOO_USER:$ODOO_USER /var/log/$ODOO_USER
echo -e "* Start ODOO"
sudo systemctl daemon-reload
sudo systemctl start $ODOO_CONFIG
sudo systemctl enable $ODOO_CONFIG


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

#--------------------------------------------------
# Firewall
#--------------------------------------------------
echo -e "==== Adjust Firewall ===="
#sudo ufw allow 'Nginx HTTP'
