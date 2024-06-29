# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BOOKSTACK_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

ENV S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install runtime packages ****" && \
  sed -i s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g /etc/apk/repositories && \
  apk add --no-cache \
    fontconfig \
    mariadb-client \
    memcached \
    php83-dom \
    php83-gd \
    php83-ldap \
    php83-mysqlnd \
    php83-pdo_mysql \
    php83-pecl-memcached \
    php83-tokenizer \
    ttf-freefont && \
  echo "**** configure php-fpm to pass env vars ****" && \
  sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
  grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf && \
  echo "**** fetch bookstack ****" && \
  mkdir -p\
    /app/www && \
  if [ -z ${BOOKSTACK_RELEASE+x} ]; then \
    BOOKSTACK_RELEASE=$(curl -sX GET "https://api.github.com/repos/bookstackapp/bookstack/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/bookstack.tar.gz -L \
    "https://mirror.ghproxy.com/https://github.com/BookStackApp/BookStack/archive/${BOOKSTACK_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/bookstack.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cp /tmp/bookstack.tar.gz /root/bookstack-${BOOKSTACK_RELEASE}.tar.gz && \
  echo "**** install composer dependencies ****" && \
  composer install -d /app/www/ && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer && \
  echo "**** apk add qt5 *** " && \
  sed -i s/3.20/3.14/g /etc/apk/repositories && \
  apk add qt5-qtbase qt5-qtwebkit qt5-qtsvg qt5-qtxmlpatterns qt5-qtdeclarative && \
  apk add --no-cache  xvfb  dbus fontconfig  && \
  fc-cache -f && \
  echo $'#!/usr/bin/env sh\nXvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \nDISPLAY=:0.0 wkhtmltopdf-origin $@ \nkillall Xvfb' > /usr/bin/wkhtmltopdf && \
  chmod +x /usr/bin/wkhtmltopdf && \
  sed -i s/3.14/3.20/g /etc/apk/repositories

#  echo "**** install fonts *** " && \
#  apk --no-cache add msttcorefonts-installer fontconfig && update-ms-fonts && \
#  fc-cache -f  && \
#  apk add wqy-zenhei --no-cache && \
#  apk add --update font-adobe-100dpi ttf-dejavu fontconfig --no-cache 

# copy local files
COPY root/ /
COPY bin/wkhtmltopdf-3.14 /usr/bin/wkhtmltopdf-origin
COPY bin/wkhtmltoimage-3.14 /usr/bin/wkhtmltoimage
COPY bin/wkhtmltopdf-patched-qt /usr/bin/wkhtmltopdf-patched-qt
COPY bin/SourceHanSansCN-Normal.otf /usr/share/fonts/

# ports and volumes
EXPOSE 80 443
VOLUME /config
