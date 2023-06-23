#!/bin/bash
ODOO_USER="odoo"
ODOO_HOME="/$ODOO_USER"
ODOO_HOME_EXIT="/$ODOO_USER/$ODOO_USER"
ODOO_PORT=8069
ODOO_VERSION=15.0
ODOO_CONFIG="${ODOO_USER}"
ODOO_SUPERADMIN="admin"

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
#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------

echo -e "\n--- Installing Python 3 + pip3 --"
#sudo apt-get install git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt1-dev -y
#sudo apt-get install libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less gdebi -y
sudo apt-get python3 python3-pip python-dev python3-dev libxml2-dev libpq-dev liblcms2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev build-essential git libssl-dev libffi-dev libjpeg-dev libblas-dev libatlas-base-dev postgresql-devel
sudo apt-get install --reinstall libpq-dev
sudo apt-get install postgresql-server postgresql-contrib postgresql-libs
echo -e "\n---- Install python packages/requirements ----"
#sudo pip3 install -r https://github.com/odoo/odoo/raw/${ODOO_VERSION}/requirements.txt

echo -e "\n---- Installing nodeJS NPM and rtlcss for LTR support ----"
sudo apt-get install nodejs npm -y
#sudo npm install -g rtlcss
sudo npm install -g less less-plugin-clean-css
sudo apt-get install -y node-less

echo -e "\n---- Create ODOO system user ----"
#sudo adduser --system --quiet --shell=/bin/bash --home=$ODOO_HOME --gecos 'ODOO' --group $ODOO_USER
#The user should also be added to the sudo'ers group.
#sudo adduser $ODOO_USER sudo
#sudo -i
#sudo su - postgres -c "createuser -s odoo"
#sudo su - postgres -c "createdb odoo"
#sudo -u postgres psql -c "ALTER USER odoo WITH SUPERUSER;"
useradd -m -d /opt/odoo -U -r -s /bin/bash odoo
#echo -e "\n---- Create Log directory ----"
#sudo mkdir /var/log/$ODOO_USER
#sudo chown $ODOO_USER:$ODOO_USER /var/log/$ODOO_USER

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
