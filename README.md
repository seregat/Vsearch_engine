

Description of :  vagarant up 
		OS: Centos 7
		Download and compiles last stable release of python  :v3.4.5 + nginx
	       Creates application installation script in:  root > ~/create-search-engine-application

_______________________________________________________________________________________
Description of :   ~/create-search-engine-application  <app_name>
 
      it will create application folder in /usr/share/<app_name>
      it will create virtualenv in /usr/share/<app_name>/env
      it will install uwsgi and configure it to work with nginx
      it will download and setup last app release from GIT
	 it will test app modules 
	 it will tests uwsgi + nginx communication
	 It will tests nginx response from dynamic and static content requests
	 It will create application UI additional services:
	     
	FOR INTERNAL USE:
		App  flask  module  path:   /usr/share/<app_name>/search_engine_env/search_engine_app/flask_app.py
		App Settings:        /usr/share/<app_name>/search_engine_env/search_engine_app/Settings/settings.ini
		Application  redefined  NGINX  and  UWSGI  configurations.
				NGINX  listens  on :	0.0.0.0:80.
				NGINX   interacts  with UWSGI  on : 	localhost:9000
				UWSGI  status	localhost:5050
				
				
				NGINX Service
				Start 	Service nginx start
				Stop	Service nginx stop
				See Status	Service  nginx  status
				Restart	Service  nginx  restart
				
				
				UWSGI Service
				Start	Service  uwsgi  start
				Stop	Service  uwsgi  stop
				Status	Service  uwsgi  status
				Restart	Service  uwsgi  restart
				
				
				
				
				NGINXCONF:
				App Config	/etc/nginx/conf.d/search_engine_app.conf
				Main Config	/etc/nginx/nginx.conf
				
				
				
				UWSGICONF:
				App uwsgi config	/usr/share/<app_name>/etc/uwsgi.ini
				
				
				
				UWSGISERVICE:
				UWSGI service	/etc/systemd/system/uwsgi.service
		     
		





     FOR PUBLIC USE:

		Update From Repository
		To pull  app  data  from  GIT	~/search-engine-pull
		
		
		App UI(NGINX+UWSGI):
		Start APP 	~/search-engine-start
		Stop APP	~/search-engine-stop
		Restart AAPP	~/search-engine-restart
		See Status	~/search-engine-status

__________________________________________________________________________________________________________________________
Permissions :

	NGINX - runs   as nginx:ngnx
	UWSGI - runs  as uwsgi:uwsgi
	
	NGINX approved to read from 
		/usr/share/<app_name> /search_engine_env/search_engine_app/static
	
	UWSGI  approved to read from 
		/usr/share/<app_name> /search_engine_env/search_engine_app
		/usr/share/<app_name> /env
		
				Permissions definion:
					find\$APPLICATION_ROOT_DIRECTORY-typed-print0|xargs-0chmod750
					chownroot:search_engine_app\$APPLICATION_ROOT_DIRECTORY
					chown-Rroot:uwsgi\$APPLICATION_ROOT_DIRECTORY/env
					chown-Rroot:search_engine_app\$APPLICATION_ROOT_DIRECTORY/search_engine_env
					find\$APPLICATION_ROOT_DIRECTORY/search_engine_env/-typef-print0|xargs-0chmod640
					chown-Rroot:uwsgi\$APPLICATION_ROOT_DIRECTORY/search_engine_env/search_engine_app/*
					chown-Rroot:nginx\$APPLICATION_ROOT_DIRECTORY/search_engine_env/search_engine_app/static
				
				
_________________________________________________________________________________________________________________


REQUESTS ARCHITECTURE 
	
	
	Static content: NGINX  <---> unix://app_static_data
	Dynamic content:    NGINX <---> 127.0.0.1:9000 <---> UWSGI <---> unix://app_dynamic_data
	



________________________________________________________________________________________________________________________________________

Must to do:

	1. Tuning of NGINX + UWSGI processes/threads  amount according to machine free RAM 
	it can be calculated programmatically during setup.
	
	2. Tuning of APPLICATION threads amount
	It can be calculated  during run time or setup process.
	
	3. Change google requests architecture
	Loads data into files and then concatenate it into response (It will keep free a lot of RAM)
	
	4. DEFINE VM RAM SIZE 
	
________________________________________________________________________________________________________________________________________





USAGE EXAMPLES:
Sources: https://github.com/seregat/Vsearch_engine  (to setup you need vagrant + provision files only)

	1. In host machine's console run:  vagrant up  --provision
	
	2. Open SSH client and connect to virtual machine(default location is: 127.0.0.1:2222):
	
	3. Login as:
	   user: vagrant
	   pwd:  vagrant
         run:  sudo -i
         run:    ~/create-search-engine-application search_engine
		
	
	
	
	4. Check app tests(all tests must be green):
	
	
	
	
	
 5. Open tunnel from some free port(localhost:8000) of HOST machine 
to locahost:80 of Virtual Machine   




	6. Now you can go to  browser localhost:8000  and to see the app
	
	
	
	
	

	
	
	
	
	




