# Install server 1C

# Quick start 1C on Ubuntu host

## 1. [Install lxc on host](https://help.ubuntu.com/lts/serverguide/lxc.html)

```
sudo apt-get update
sudo apt-get install lxc 
```

## 2. Create servers for DB and 1C in LXC

```
sudo lxc-create -t download -n srvdb -- -d ubuntu -r xenial -a amd64
sudo lxc-create -t download -n srv1c -- -d ubuntu -r xenial -a i386
sudo lxc-start -n srvdb
sudo lxc-start -n srv1c
sudo lxc-info -n srv1c
sudo lxc-info -n srvdb
#add ip for srv1c to /etc/hosts
```

## 3. [Install postgres on srvdb](https://postgrespro.ru/products/1c_build) 
```
sudo lxc-attach -n srvdb
locale-gen ru_RU.UTF-8
update-locale LANG=ru_RU.UTF-8
locale
sh -c 'echo "deb http://1c.postgrespro.ru/deb/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro-1c.list'
wget --quiet -O - http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C | sudo apt-key add - && sudo apt-get update
apt-get install postgresql-pro-1c-9.6
/etc/init.d/postgresql start
su - postgres
psql
postgres=# \password postgres
\q
exit
```
Database is ready. For tuning see [Configure PostgreSQL](https://its.1c.ru/db/metod8dev#content:5866:hdoc)

## 4. Install 1C server from [deb packages](https://releases.1c.ru/version_files?nick=Platform83&ver=8.3.10.2466)   
```
sudo lxc-attach -n srv1c
apt-get update
apt-get install apache2 openssh-server
#Downloads deb to 1c
dpkg -i 1c/* 

#Public demo on server
/opt/1C/v8.3/i386/webinst -apache24 -wsdir demo -dir '/var/www/html/demo' -connStr 'Srvr="localhost";Ref="demo";'
service apache2 restart
service srv1cv83 restart

## Look ports for 1C 
netstat -ltpn 

#add ip for srvdb to /etc/hosts
exit
```

## 5. Configure NGINX.
Get keys for nginx from [www.sslforfree.com](https://www.sslforfree.com/) 

```
sudo apt-get install nginx

# Move ca_bundle.crt, certificate.crt and private.key to /etc/nginx/ssl/ 
```
Add to /etc/nginx/nginx.conf
```
    server {
              #listen 80;
    	      listen 443 ssl;
              server_name host;

              # location of key and certificate files
              ssl_certificate /etc/nginx/ssl/certificate.crt;
              ssl_certificate_key /etc/nginx/ssl/private.key;

              # cache ssl sessions 
              ssl_session_cache  builtin:1000  shared:SSL:10m;    

              # prefer server ciphers (safer)
              ssl_prefer_server_ciphers on;

         
              location / {
                proxy_pass http://srv1c;
        	    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         	    proxy_set_header X-Forwarded-Proto $scheme;
         	    proxy_set_header X-Real-IP $remote_addr;
         	    proxy_set_header Host $http_host;
                proxy_cache_bypass $http_upgrade;
              }
	}
```

Reload nginx
```
sudo nginx -s reload
```

## 6. Create tunnel to 1C server on PC with 1C Platform (see ports step #4)

```
ssh -gL 1540:srv1c:1540 1541:srv1c:1541 1560:srv1c:1640 host
```
Install 1C configuration on 1C server
 
## 7. Try to connect from firefox:
```
 https://host/demo
```

