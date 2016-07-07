#!/usr/bin/env bash
sudo -i
sudo yum -y update
sudo yum -y install python libxml2 libxml2-devel python-setuptools zlib-devel wget openssl-devel pcre pcre-devel sudo gcc make autoconf automake kernel-devel
sudo yum -y groupinstall "Development Tools"
sudo yum -y install epel-release
sudo yum install python-pip python-devel nginx gcc
sudo yum install -y vim-X11 vim-common vim-enhanced vim-minimal
sudo yum -y install net-tools strace socat
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


mkdir /usr/share/search_engine_env_serve
cd /usr/share/search_engine_env_serve
virtualenv3.4 env
source env/bin/activate
pip3.4 install --upgrade pip


#START INSTALL APPLICATION
git init
git remote add -f origin https://github.com/seregat/Vsearch_engine.git
git config core.sparseCheckout true
echo "search_engine_app" >> .git/info/sparse-checkout
git pull origin master
python3.4 search_engine_env/setup.py install
#END INSTALL APPLICATION



#this option
#pip3.4 install search_engine_app
deactivate

pip3.4 install --upgrade pip
pip3.4 install uwsgi
ln -s /usr/share/search_engine_env_serve/env/lib/python3.4/site-packages/search_engine_app  usr/share/search_engine_env_serve/app
ln -s /usr/share/search_engine_env_serve/env/lib/python3.4/site-packages  usr/share/search_engine_env_serve/src
mkdir /usr/share/search_engine_env_serve/etc



cat > /etc/systemd/system/search_engine_uwsgi.service <<EOF
[Unit]
Description=Search Engine uwsgi Service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/usr/share/search_engine_env_serve
Environment="PATH=/usr/share/search_engine_env_serve/env/bin"
ExecStartPre=/bin/sh -c "systemctl start nginx"
ExecStart=/bin/sh -c "source /usr/share/search_engine_env_serve/env/bin/activate"
ExecStartPost=/bin/sh -c "uwsgi --ini /usr/share/search_engine_env_serve/etc/uwsgi.ini"
[Install]
WantedBy=multi-user.target
EOF


cat > /etc/systemd/system/search_engine_serve.service <<EOF
[Unit]
Description=Search Engine Service
After=network.target

[Service]
Type=forking
User=root
Group=root
ExecStart=/bin/sh -c "service nginx start&;service search_engine_uwsgi start&"
ExecStop=/bin/sh -c "service nginx stop;service search_engine_uwsgi stop"
[Install]
WantedBy=multi-user.target
EOF


cat > /usr/share/search_engine_env_serve/etc/uwsgi.ini <<EOF
[uwsgi]
wsgi-file = /usr/share/search_engine_env_serve/app/flask_app.py
home =  /usr/share/search_engine_env_serve/env
pythonpath =  /usr/share/search_engine_env_serve/src
virtualenv = /usr/share/search_engine_env_serve/env
callable = app
master = true
socket = localhost:9000
vacuum = true
processes = 2
uid = vagrant
gid = vagrant
pidfile = /tmp/bc_local.pid
no-site = True
enable-threads = True
py-autoreload = 1
disable-logging = 1
die-on-term = true
EOF

cat >  /etc/nginx/nginx.conf<<EOF
user vagrant;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  search_engine_app;
        include /etc/nginx/default.d/*.conf;
        location / {
                include         uwsgi_params;
                uwsgi_pass      localhost:9000;
        }
        location /static {
            root  /usr/share/search_engine_env_serve/app/;
        }

        root         /usr/share/search_engine_env_serve/app/static;

        error_page 404 /404.html;
            location = /usr/share/search_engine_env_serve/app/templates/404.html{
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }
}

EOF





sudo systemctl start search_engine_serve
sudo systemctl enable search_engine_serve





