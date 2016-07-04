          :-)
:-)Think different :-)
          :-)

To run this project you need python 3.4
If you have this so skip step 1 and go to step 2 directly

Step 1: Install python3.4.5

            sudo yum -y update
            sudo yum -y install python libxml2 libxml2-devel python-setuptools zlib-devel wget openssl-devel pcre pcre-devel sudo gcc make autoconf automake kernel-devel
            sudo yum -y groupinstall "Development Tools"
            sudo yum -y install epel-release
            sudo yum install python-pip python-devel nginx gcc
            sudo yum install -y vim-X11 vim-common vim-enhanced vim-minimal
            sudo yum install -y htop
            sudo yum install -y vim
            sudo yum install -y nginx
            sudo yum install -y wget
            wget https://www.python.org/ftp/python/3.4.5/Python-3.4.5.tar.xz
            tar -xvf Python-3.4.5.tar.xz
            cd Python-3.4.5
            ./configure
            make
            make install
            ln -s /usr/local/bin/pip3.4 /usr/bin/pip3.4
            ln -s /usr/local/bin/pyvenv-3.4 /usr/bin/virtualenv3.4

Step 2 : Setup project in vertual environment inside folder: /usr/share/search_engine_env_serve

            mkdir /usr/share/search_engine_env_serve
            virtualenv3.4 env
            source env/bin/activate
            python3.4 setup.py install



Step 3: Run project's flask server : 'serve' - service command that will run flask server it descibed in setup.py

            serve

_____________________________________________
By Default flask server listens on port:5000