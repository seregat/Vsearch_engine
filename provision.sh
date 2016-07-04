sudo -i

sudo yum -y update
sudo yum -y install python libxml2 libxml2-devel python-setuptools zlib-devel wget openssl-devel pcre pcre-devel sudo gcc make autoconf automake kernel-devel
sudo yum -y groupinstall "Development Tools"
sudo yum -y install epel-release
sudo yum install python-pip python-devel nginx gcc
sudo yum install -y vim-X11 vim-common vim-enhanced vim-minimal




#yum clean all
#yum makecache


sudo yum install -y htop
sudo yum install -y vim
sudo yum install -y nginx
sudo yum install -y wget
wget https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tar.xz
tar -xvf Python-3.4.5.tar.xz

cd Python-3.4.5
./configure
make
make install
ln -s /usr/local/bin/pip3.4 /usr/bin/pip3.4
ln -s /usr/local/bin/pyvenv-3.4 /usr/bin/virtualenv3.4
cd /usr/share
mkdir /usr/share/search_engine_env_serve
cd /usr/share/search_engine_env_serve
#rm -rf /usr/share/search_engine_env_serve
#cp -r /usr/share/search_engine_env /usr/share/search_engine_env_serve
#cd /usr/share/search_engine_env_serve
#find /usr/share/search_engine_env_serve -type d -print0 | xargs -0 chmod 770 
#find /usr/share/search_engine_env_serve -type f -print0 | xargs -0 chmod 660
#chown -R  vagrant:vagrant  /usr/share/search_engine_env_serve
virtualenv3.4 env
source env/bin/activate
#python3.4 setup.py install
pip3.4 install --upgrade pip
#pip3.4 install uwsgi
#python3.4 setup.py register sdist upload
pip3.4 install search_engine_app
#this service defined in search_engine_env_serve/setup.py




cat > /etc/systemd/system/search_engine.service <<EOF
[Unit]
Description=Flask Search Engine Service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/usr/share/search_engine_env_serve
Environment="PATH=/usr/share/search_engine_env_serve/env/bin"
ExecStart=/usr/share/search_engine_env_serve/env/bin/serve

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl start search_engine
sudo systemctl enable search_engine

service search_engine status




