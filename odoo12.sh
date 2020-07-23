yum update
yum install epel-release -y
yum install centos-release-scl -y
yum install git wget ibxslt-devel bzip2-devel openldap-devel libjpeg-devel freetype-devel -y
sudo yum groupinstall 'Development Tools' -y
## Gist url
export GIST_URL="https://gist.githubusercontent.com/daothanh/2f9be5af944e7cb92c84ceb64c4bc3fd/raw"
export ODOO_DOMAIN=webcongty.pro
export ODOO_PASSWORD=abc@123

export PERL_UPDATE_ENV="perl -p -e 's/\{\{([^}]+)\}\}/defined \$ENV{\$1} ? \$ENV{\$1} : \$&/eg' "
 [[ -z $SYSTEM ]] && echo "Don't forget to define SYSTEM variable"
 
# Install Postpresql
yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos11-11-2.noarch.rpm
yum install -y postgresql11-server.x86_64 postgresql11-contrib.x86_64
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl start postgresql-11
sudo systemctl enable postgresql-11
# Create odoo user
su - postgres -c "createuser -s odoo"

# Install wkhtmltox
yum install -y https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox-0.12.5-1.centos7.x86_64.rpm

# Install Python 3
yum install -y centos-release-scl
yum install -y rh-python36
scl enable rh-python36 bash

#Install Nginx
cd /etc/yum.repos.d/
wget -q ${GIST_URL}/nginx.repo -O nginx.repo
yum update
yum install nginx -y
systemctl enable nginx
service start nginx

# Install Certbot
yum -y install yum-utils
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
yum -y install python2-certbot-nginx

# Install Odoo
su - odoo
cd /opt/odoo
git clone https://www.github.com/odoo/odoo --depth 1 --branch 12.0 /opt/odoo/odoo
scl enable rh-python36 bash
python -m venv odoo-venv
source odoo12-venv/bin/activate
# Upgrade pip
pip install --upgrade pip
pip install wheel
pip install -r odoo/requirements.txt
deactivate && exit
exit
mkdir /opt/odoo/odoo-custom-addons
chown odoo: /opt/odoo/odoo-custom-addons

# Odoo config
cd /etc/
wget -q ${GIST_URL}/odoo.conf -O odoo.conf
eval "${PERL_UPDATE_ENV} < odoo.conf" | sponge odoo.conf

# Install and anable odoo service
cd /etc/systemd/system/
wget -q ${GIST_URL}/odoo.service -O odoo.service
systemctl daemon-reload
systemctl start odoo
systemctl enable odoo
# Set enforce
setenforce 0

# Config nginx
cd /etc/nginx/con.d/
wget -q ${GIST_URL}/nginx-odoo.conf -O odoo.conf
eval "${PERL_UPDATE_ENV} < odoo.conf" | sponge odoo.conf

service nginx restart
