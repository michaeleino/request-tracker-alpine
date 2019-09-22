FROM alpine:3.10

LABEL maintainer="Michael Fayez <smsconnectivity@arpuplus.com>" \
      Version="4.4.4-2"

# Add system service config
ADD ./config/ /src/config/

# Set up APK
RUN apk update && apk upgrade && \
  # Install required packages
  apk add rt4 git make perl-module-install perl-graphviz perl-gd msmtp \
          spawn-fcgi nginx supervisor
# clean cache to save some space
  # apk cache --purge --progress
RUN \
#Install RT extensions
    mv /src/config/RT_SiteConfig.pm /etc/rt4/RT_SiteConfig.pm && \
    mv /src/config/scripts/rt-install-ext.sh /usr/bin/ && \
    rt-install-ext.sh "https://github.com/bestpractical/rt-extension-mergeusers" && \
    rt-install-ext.sh "https://github.com/bestpractical/rt-extension-commandbymail" && \
# install getmail manually till it become available at repo
    wget http://pyropus.ca/software/getmail/old-versions/getmail-5.14.tar.gz -O /src/getmail.tar.gz && \
    mkdir /src/getmail && tar xzvf /src/getmail.tar.gz --strip-components=1 --directory /src/getmail && \
    cd /src/getmail && \
    python setup.py install && \
    mkdir /var/spool/getmail && \
##adding supervisord conf files
    mkdir /run/nginx/  && \
    mv /src/config/supervisor.d /etc/ && \
##adding nginx conf
    mv /src/config/nginx.conf /etc/nginx/nginx.conf && \
#clean things for space
    apk del make && \
    rm -r /src/

VOLUME ["/etc/rt4/RT_SiteConfig.d/"]
VOLUME ["/var/log/"]
EXPOSE 80
EXPOSE 443
# CMD ["rt-server"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
