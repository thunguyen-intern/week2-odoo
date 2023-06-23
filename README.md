# Week 2: Install Odoo and Setup configurations

## Installation
## Setup
### Using 1 server
Run provision on 1 server: setup Vagrantfile to default by importing a virtualbox (I'm using Ubuntu 20) and setup config. Remember to mount a port.
```bash
vagrant up
vagrant reload --provision
vagrant ssh
```

### Using different servers
The Vagrantfile is designed to combine provision between PostgreSQL -> Odoo -><- NGINX.
```bash
vagrant up
vagrant reload $name --provision
vagrant ssh $name
```

