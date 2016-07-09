#!/bin/bash

sudo -i

echo 'START INSTALL PYTHON3.4'
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
#sudo yum install -y uwsgi
sudo yum install -y wget
wget https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tar.xz
tar -xvf Python-3.4.5.tar.xz
cd Python-3.4.5
./configure
make
make install
ln -s /usr/local/bin/pyvenv-3.4 /usr/bin/virtualenv3.4
echo 'END INSTALL PYTHON3.4'







cat > ~/create-search-engine-application <<EOF_create-search-engine-application
#!/bin/bash

APPLICATION_ROOT_DIRECTORY="/usr/share/\${1}"


if [ -d "\$APPLICATION_ROOT_DIRECTORY" ]
then
           tput setaf 1;
           echo "App Directory already exists '\$APPLICATION_ROOT_DIRECTORY'. Please remove it before or chooe an another application name"
           tput sgr0
           exit 0
fi

tput setaf 2;
echo '******************************************************************************'
echo '******************************************************************************'
echo '******************************************************************************'
echo "START DEFINE SCRIPT TO CREATE SEARCH ENGINE APP \$1 in \$APPLICATION_ROOT_DIRECTORY"
echo '******************************************************************************'
echo '******************************************************************************'
echo '******************************************************************************'
tput sgr0



echo 'START DEFINE VIRTUAL ENV'
mkdir -p \$APPLICATION_ROOT_DIRECTORY
mkdir \${APPLICATION_ROOT_DIRECTORY}/etc
cd \$APPLICATION_ROOT_DIRECTORY
virtualenv3.4 env
source env/bin/activate
pip3.4 install --upgrade pip
pip3.4 install uwsgi
pip3.4 install green
ln -s \${APPLICATION_ROOT_DIRECTORY}/env/lib/python3.4/site-packages \${APPLICATION_ROOT_DIRECTORY}/src
deactivate
echo 'END DEFINE VIRTUAL ENV'









echo 'START DEFINE APP PLACES'
groupadd  search_engine_app
useradd uwsgi
usermod -a -G search_engine_app nginx
usermod -a -G search_engine_app uwsgi
usermod -a -G nginx uwsgi
echo 'END DEFINE APP PLACES'












echo 'START DEFINE GIT SPARE CHEKOUT'
git init
git remote add -f origin https://github.com/seregat/Vsearch_engine.git
git config core.sparseCheckout true
echo "search_engine_env" >> .git/info/sparse-checkout
echo  'END DEFINE GIT SPARE CHEKOUT'












echo 'START DEFINE UPDATE FROM GIT REPOSITORY'
cat > ~/search-engine-pull <<EOF
#!/bin/bash
cd \$APPLICATION_ROOT_DIRECTORY
git pull origin master
source \${APPLICATION_ROOT_DIRECTORY}/env/bin/activate
python3.4 search_engine_env/setup.py install

echo 'START RUN UNITESTS'
green search_engine_env
echo 'END  RUN UNITESTS'

deactivate
find \$APPLICATION_ROOT_DIRECTORY -type d -print0 | xargs -0 chmod 750
chown root:search_engine_app \$APPLICATION_ROOT_DIRECTORY
chown -R root:uwsgi \$APPLICATION_ROOT_DIRECTORY/env
chown -R root:search_engine_app \$APPLICATION_ROOT_DIRECTORY/search_engine_env
find \$APPLICATION_ROOT_DIRECTORY/search_engine_env/ -type f -print0 | xargs -0 chmod 640
chown -R root:uwsgi \$APPLICATION_ROOT_DIRECTORY/search_engine_env/search_engine_app/*
chown -R root:nginx \$APPLICATION_ROOT_DIRECTORY/search_engine_env/search_engine_app/static
EOF
chmod 700 ~/search-engine-pull
echo 'END DEFINE UPDATE FROM GIT REPOSITORY'











echo 'START APP UPDATE/INSTALL + GIT PULL'
~/search-engine-pull
echo 'END APP UPDATE/INSTALL + GIT '











echo 'START DEFINE VIRTUAL ENV PYTHON PATHES'
cat >  \${APPLICATION_ROOT_DIRECTORY}/src/application_pathes.pth <<EOF
\$APPLICATION_ROOT_DIRECTORY
\${APPLICATION_ROOT_DIRECTORY}/search_engine_env
EOF
echo 'END DEFINE VIRTUAL ENV PYTHON PATHES'










echo 'START DEFINE UWSGI CONFIG'
cat >  \${APPLICATION_ROOT_DIRECTORY}/etc/uwsgi.ini <<EOF
[uwsgi]
wsgi-file =\${APPLICATION_ROOT_DIRECTORY}/search_engine_env/search_engine_app/flask_app.py
home=\${APPLICATION_ROOT_DIRECTORY}/env
virtualenv=\${APPLICATION_ROOT_DIRECTORY}/env
callable = app
master = true
socket = localhost:9000
vacuum = true
processes = 2
uid = uwsgi
gid = uwsgi
enable-threads = True
py-autoreload = 1
disable-logging = 1
die-on-term = true
plugin=python3.4
#stats=localhost:5050
EOF
chown -R uwsgi:uwsgi \${APPLICATION_ROOT_DIRECTORY}/etc/uwsgi.ini
echo 'END DEFINE UWSGI CONFIG'












echo 'START DEFINE UWSGI systemd SERVICE'
cat > /etc/systemd/system/uwsgi.service <<EOF
[Unit]
Description=uWSGI Search Engine Service

[Service]
ExecStartPre=-/usr/bin/bash -c 'mkdir -p /run/uwsgi; chown uwsgi:uwsgi /run/uwsgi'
ExecStart=/usr/bin/bash -c 'cd \${APPLICATION_ROOT_DIRECTORY}; source env/bin/activate; uwsgi --ini \${APPLICATION_ROOT_DIRECTORY}/etc/uwsgi.ini'
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT
Restart=always
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
echo 'END DEFINE UWSGI systemd SERVICE'









echo 'START DEFINE NGINX CONFIG'
cat >/etc/nginx/nginx.conf<<EOF
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [\$time_local] "$request" '
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
}

EOF

cat >  /etc/nginx/conf.d/search_engine_app.conf<<EOF
server {

    client_max_body_size 2M;
    listen       80;
    listen       [::]:80;
    location / {
            include         uwsgi_params;
            uwsgi_pass      localhost:9000;
            uwsgi_read_timeout 600;
    }
    location /static {
        #access_log off;
        #expires 1d;
        root  \${APPLICATION_ROOT_DIRECTORY}/search_engine_env/search_engine_app/;
    }
    gzip on;
    gzip_min_length 256;
    gzip_disable "msie6";
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon;
}
EOF
echo 'END DEFINE NGINX CONFIG'












echo 'START INITIALISATION UWSGI+NGINX'
systemctl enable uwsgi
systemctl enable nginx
systemctl start uwsgi
systemctl start nginx
echo 'END INITIALISATION  UWSGI+NGINX'









echo 'START APP UI DEFINITION'
cat > ~/search-engine-start <<EOF
#!/bin/bash

service nginx start
service uwsgi start
EOF
chmod 700 ~/search-engine-start

cat > ~/search-engine-stop <<EOF
#!/bin/bash

service nginx stop
service uwsgi stop
EOF
chmod 700 ~/search-engine-stop



cat > ~/search-engine-status <<EOF
#!/bin/bash

service nginx status
service uwsgi status
EOF
chmod 700 ~/search-engine-status

cat > ~/search-engine-restart <<EOF
#!/bin/bash

service nginx restart
service uwsgi restart
EOF
chmod 700 ~/search-engine-restart
echo 'END APP UI DEFINITION'


~/search-engine-restart











tput setaf 4;
echo '******************************************************************************'
echo '******************************************************************************'
echo '**************************APP INSTALATION REPPORT*****************************'
echo '******************************************************************************'
tput sgr0

tput setaf 4;
echo "NGINX + UWSGI STATUSES"
tput sgr0
~/search-engine-status


tput setaf 4;
echo "APP TESTS"
tput sgr0

source \${APPLICATION_ROOT_DIRECTORY}/env/bin/activate
green search_engine_env

#!/bin/bash


echo 'Testing: http://localhost'
ouputFromDynamicContentExistingResponse=\$(curl -I http://localhost | head -n 1 | cut -d " " -f 2)
if [ \$ouputFromDynamicContentExistingResponse -eq "200" ]
then
         tput setaf 2
         echo 'NGINX-UWSGI bundle OK (loads dynamic content)'
         tput sgr0
else
         tput setaf 1
         echo -e "NGINX-UWSGI bundle FAILED (It doesn't load dynamic content) respone:\n"
         curl -I http://localhost
         tput sgr0
fi


echo 'Testing non existing content: http://localhost/not_exists_data'

ouputFromStaticContentNotFoundResponse=\$(curl -I http://localhost/not_exists_data | head -n 1 | cut -d " " -f 2)
if [ \$ouputFromStaticContentNotFoundResponse -eq "404" ]
then
        tput setaf 2
        echo 'NGINX-UWSGI bundle OK (NOT FOUND routing is working)'
        tput sgr0
else
        tput setaf 1
        echo -e "NGINX-UWSGI bundle FAILED (NOT FOUND routing is not working) respone:\n"
        curl -I http://localhost/not_exists_data
        tput sgr0
fi


echo 'Testing static content: http://localhost/static/404.jpg'

ouputFromStaticContentExistingResponse=\$(curl -I http://localhost/static/404.jpg | head -n 1 | cut -d " " -f 2)

if [ \$ouputFromStaticContentExistingResponse -eq "200" ]
then
         tput setaf 2
         echo 'NGINX STATIC CONTENT PROCESSION OK'
         tput sgr0
else
        tput setaf 1
        echo 'NGINX STATIC CONTENT PROCESSION FAILED response:\n'
        curl -I http://localhost/static/404.jpg
        tput sgr0
fi



tput setaf 3
printf  "%s" "
SEARCH ENGINE APPLICATION
Aplication created in \$APPLICATION_ROOT_DIRECTORY
App flask module path: \${APPLICATION_ROOT_DIRECTORY}/search_engine_env/search_engine_app/flask_app.py
Application redefined NGINX and UWSGI configurations.
NGINX listens on port 0.0.0.0:80 .
NGINX interacts with UWSGI on port localhost:9000
UWSGI status: localhost:5050


You can pull app data from GIT
    ~/search-engine-pull

You can controll the app via:
    ~/search-engine-start
    ~/search-engine-stop
    ~/search-engine-restart
    ~/search-engine-status

You can control NGINX server via:
    service nginx start
    service nginx stop
    service nginx status
    service nginx restart

You can control UWSGI server via:
    service uwsgi start
    service uwsgi stop
    service uwsgi status
    service uwsgi restart



NGINX CONF:
       /etc/nginx/conf.d/search_engine_app.conf
       /etc/nginx/nginx.conf

UWSGI CONF:
       \${APPLICATION_ROOT_DIRECTORY}/etc/uwsgi.ini

UWSGI SERVICE:
       /etc/systemd/system/uwsgi.service


"
tput sgr0

tput setaf 2;
echo '******************************************************************************'
echo '******************************************************************************'
echo '******************************************************************************'
echo "END DEFINE SCRIPT TO CREATE SEARCH ENGINE APP in \$APPLICATION_ROOT_DIRECTORY"
echo '******************************************************************************'
echo '******************************************************************************'
echo '******************************************************************************'
tput sgr0


EOF_create-search-engine-application


chmod 700 ~/create-search-engine-application

echo TO INSTALL APPLICATION  USE: ~/create-search-engine-application you_app_name
