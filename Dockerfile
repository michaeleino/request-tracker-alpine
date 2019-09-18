FROM alpine:3.10

LABEL maintainer="Michael Fayez <smsconnectivity@arpuplus.com>"

# Add system service config
ADD ./config/ /src/config/

# Set up APK
RUN apk update && apk upgrade && \
  # Install required packages
  apk add rt4 git make perl-module-install perl-graphviz perl-gd && \
# clean cache to save some space
  # apk cache --purge --progress
# RUN \
#Install RT extensions
    mv /src/config/RT_SiteConfig.pm /etc/rt4/RT_SiteConfig.pm && \
    mv /src/config/scripts/installext.sh /src/installext.sh && \
    /src/installext.sh "https://github.com/bestpractical/rt-extension-mergeusers" && \
    /src/installext.sh "https://github.com/bestpractical/rt-extension-commandbymail" && \
#clean things for space
    apk del git make perl-module-install && \
    rm -r /src/config

CMD ["rt-server"]

VOLUME ["/etc/rt4/RT_SiteConfig.d/"]
EXPOSE 80
EXPOSE 443
