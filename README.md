# request-tracker-alpine
request tracker alpine

-RT 4.4.4  
-supervisor  
-nginx  
-spawn-fcgi  
-msmtp  
-getmail  


#### RT on Linux Alpine
 ====================

This is a docker image for running Best Practical's RT V4.x (Request Tracker), a ticket tracking system.

the image will exposes the RT web interface on container port 80 and 443.
and will connect by default to MySQL database.


# Getting Starting
 -----------------

- Start a Mysql/Mariadb container:  
 if you have an existing running DB, skip this step and go down for RT4:  
  for ref: `https://hub.docker.com/_/mariadb/`

  ```$ docker run \
    --name some-mariadb \
    --hostname myhostname \
    -p 3306:3306
    -v /my/own/datadir:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=my-secret-pw \
    -d mariadb:tag \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_unicode_ci
```

- Now the database is running and you can run RT using:  
  `/etc/rt4-docker/` is where you decide to store RT data, log and external configuration.

```
    $ docker run -d \
      --name rt4 \
      --hostname ticketing.arpuplus.com \
      --restart unless-stopped \
      -p 443:443 -p 80:80 \
      -v /etc/rt4-docker/RT_SiteConfig.d:/etc/rt4/RT_SiteConfig.d \
      -v /etc/rt4-docker/scripts:/etc/rt4/scripts \
      -v /etc/rt4-docker/log:/var/log \
      -v /etc/rt4-docker/rt4-cron:/etc/crontabs/nginx \
      -e DATABASE_HOST=DBHOST \
      -e DATABASE_USER=rt_user \
      -e DATABASE_PASSWORD=rt_pass \
      -e DATABASE_NAME=rt4 \
      arpuplus/rt4:4.4.4.05
```
To check the ports on which the web interfaces are exposed, run `docker ps`.

You can now initialize the database by going to the web interface of RT4 container IP:port.

But preferably go to ash shell and initialize the DB from there by:  
 `rt-setup-database --action init`


configuration
-------------
This image provides some limited support for customizing the deployment using
environment variables. See RT_SiteConfig.pm for details, and most probably you will need to map an external directory from host to the container like:  
    `-v /etc/rt4-docker/RT_SiteConfig.d:/etc/rt4/RT_SiteConfig.d`

Available vars:
---------------
```
RT_NAME                 defaults to example.com
Organisation            defaults to example.com
WEB_DOMAIN              defaults to example
WEB_PORT                defaults to 80
LOG_LEVEL               defaults to info
DATABASE_TYPE           defaults to MySQL
DATABASE_HOST
DATABASE_PORT           defaults to MySQL 3306
DATABASE_NAME           defaults to rt4
DATABASE_USER           defaults to rt_user
DATABASE_PASSWORD       defaults to rt_pass
```

- The image has an hourly cronjob for full text index  
```rt-fulltext-indexer -> /usr/sbin/rt-fulltext-indexer```

You need to start the indexer setup once after the first installation, selecting your DB type and table name, then add the configuration from the output to your RT_SiteConfig.pm  

```/usr/sbin/rt-setup-fulltext-index --dba rt_user --dba-password rt_pass```  


Extensions:
-----------
The image is built with mergeusers and CommandByMail extensions and enabled in the conf.

```
  -   https://github.com/bestpractical/rt-extension-mergeusers  
  -   https://github.com/bestpractical/rt-extension-commandbymail
```

Extra Extensions:
=================
To install an extension, go to the container cli by  
  ```$ docker exec -it CONTAINER-NAME ash```
then run the below, and substitue the URL of the extension needed:  
  `rt-install-ext.sh "https://github.com/bestpractical/rt-extension-EXTNAME"`
