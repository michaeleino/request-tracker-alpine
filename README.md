# request-tracker-alpine
request tracker alpine


#docker-rt4 on Linux Alpine
===========================

This is a docker image for running Best Practical's RT V4.x (Request Tracker), a ticket tracking system.

the image will exposes the RT web interface on container port 80 and 443.
and will connect by default to MySQL database.


#Getting Starting
-----------------

-Start a Mysql/Mariadb container:
 if you have an existing running DB, skip this step and go down for RT4
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

-Now the database is running and you can run RT using:

  ```$ docker run -d \
    --name rt \
    --hostname rt.example.com
    -p 443 \
    -p 80 \
    -v /my/host/data/dir:/etc/rt4/RT_SiteConfig.d \
    -e DATABASE_HOST=dbserver \
    -e DATABASE_USER=rt_user \
    -e DATABASE_PASS=rt_pass \
    -e DATABASE_NAME=rt4 \
    arpuplus/rt4:4.4.4-1
```
To check the ports on which the web interfaces are exposed, run `docker ps`.

You can now initialize the database by going to the web interface of RT4 container IP:port.

But preferably go to bash and initialize the DB from there by:
 ```rt-setup-database --action init```


configuration
-------------
This image provides some limited support for customising the deployment using
environment variables. See RT_SiteConfig.pm for details.

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
DATABASE_PASSWORD       defaults to rt_user
```

Extensions:
===========
The image is built with mergeusers and CommandByMail extensions and enabled in the conf.
```  https://github.com/bestpractical/rt-extension-mergeusers
  https://github.com/bestpractical/rt-extension-commandbymail```

Extra Extensions:
=================
To install an extension, go to the container cli by
  ```$ docker exec -it CONTAINER-NAME ash```
then run the below, and substitue the URL of the extension needed:
  ```/src/installext.sh "https://github.com/bestpractical/rt-extension-EXTNAME"```
