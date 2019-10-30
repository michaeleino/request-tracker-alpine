FROM alpine:3.10

LABEL maintainer="Michael Fayez <smsconnectivity@arpuplus.com>" \
      Version="4.4.4.07"

ARG CKEVERSION=4.13.0
ARG GETMAILVERSION=5.14

# Add system service config
ADD ./config/ /src/config/

# Set up APK
RUN apk update && apk upgrade && \
  # Install required packages
  apk add rt4 git make perl-module-install perl-graphviz perl-gd perl-gdgraph perl-gdtextutil \
          spawn-fcgi nginx supervisor \
          postfix cyrus-sasl-login
# clean cache to save some space
  # apk cache --purge --progress
RUN \
#Install RT extensions
    #echo "CKE=$CKEVERSION.zip and getmail=$GETMAILVERSION" && \
    mv /src/config/RT_SiteConfig.pm /etc/rt4/RT_SiteConfig.pm && \
    mv /src/config/scripts/rt-install-ext.sh /usr/bin/ && \
     rt-install-ext.sh "https://github.com/bestpractical/rt-extension-mergeusers" && \
     rt-install-ext.sh "https://github.com/bestpractical/rt-extension-commandbymail" && \
#Custom RT modifications
  # set X-Managed-by
    orgnmngdby='"RT $RT::VERSION (http:\/\/www.bestpractical.com\/rt\/)"' && \
    newmngdby="RT->Config->Get('Organization')" && \
    sed -i -e "s/$orgnmngdby/$newmngdby/g" /usr/lib/rt4/RT/Action/SendEmail.pm && \
    # add hourly cronjob for full text index
    ln -s /usr/sbin/rt-fulltext-indexer /etc/periodic/hourly/ && \
  # add the full lastet ckeditor
  cd /src/ && \
  wget "https://download.cksource.com/CKEditor/CKEditor/CKEditor%20${CKEVERSION}/ckeditor_${CKEVERSION}_full.zip" && \
  unzip ckeditor_${CKEVERSION}_full.zip && rm ckeditor_${CKEVERSION}_full.zip && \
  mv /usr/share/rt4/static/RichText /usr/share/rt4/static/RichText.orgn && \
  mv ckeditor /usr/share/rt4/static/RichText && \
  ## removing the background-color to match the original red/yellow for reply/comment in the ckeditor
  sed -i 's/background-color: #fff;//g' /usr/share/rt4/static/RichText/contents.css && \
# install getmail manually till it become available at repo
    wget http://pyropus.ca/software/getmail/old-versions/getmail-${GETMAILVERSION}.tar.gz -O /src/getmail.tar.gz && \
    mkdir /src/getmail && tar xzvf /src/getmail.tar.gz --strip-components=1 --directory /src/getmail && \
    cd /src/getmail && \
    python setup.py install && \
    mkdir /var/spool/getmail && \
    chown -R nginx:www-data /var/spool/getmail && \
##adding supervisord conf files
    mkdir /run/nginx/  && \
    mv /src/config/supervisor.d /etc/ && \
##adding nginx conf
    mv /src/config/nginx.conf /etc/nginx/nginx.conf && \
##postfix configs
  cp /etc/postfix/main.cf /etc/postfix/main.cf.dist && \
  mv /src/config/scripts/postconf.sh /usr/bin/ && \
#clean things for space saving
    apk del make && \
    rm -r /src/

VOLUME ["/etc/rt4/RT_SiteConfig.d/"]
VOLUME ["/var/log/"]
EXPOSE 80
EXPOSE 443
# CMD ["rt-server"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
