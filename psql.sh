#!/bin/bash
ODOO_USER="odoo"

echo -e "\n---- Install PostgreSQL Server ----"
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get install postgresql -y
sudo systemctl start postgresql
sudo systemctl enable postgresql
sudo -i
su - postgres -c "createuser -s $ODOO_USER"
su - postgres -c "createdb odoo"
sudo -u postgres psql -c "ALTER USER odoo WITH SUPERUSER;"
