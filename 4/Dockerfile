FROM debian:13-slim

ARG SITE_USER=www-data
ARG SITE_GROUP=www-data

#ENV DEBIAN_FRONTEND=noninteractive

#RUN set -eux; \
#    rm -f /etc/apt/sources.list.d/debian.sources; \
#    echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/debian.list; \
#    apt-get update; \
#    apt-get upgrade -y; \
#    apt-get install -y --no-install-recommends nginx procps; \
#    apt-get clean; \
#    rm -rf /var/lib/apt/lists/* /var/www/*; \
#    mkdir -p /var/www/vatrubin.ru/img; \
#    useradd --system --create-home --shell /usr/sbin/nologin "${SITE_USER}"; \
#    groupadd "${SITE_GROUP}"; \
#    usermod -aG "${SITE_GROUP}" "${SITE_USER}"

RUN rm -f /etc/apt/sources.list.d/debian.sources; \
    printf '%s\n' \
    "deb http://ftp.ru.debian.org/debian/ stable main contrib non-free" \
    "deb-src http://ftp.ru.debian.org/debian/ stable main contrib non-free" \
    "deb http://ftp.ru.debian.org/debian/ stable-updates main contrib non-free" \
    "deb-src http://ftp.ru.debian.org/debian/ stable-updates main contrib non-free" \
    > /etc/apt/sources.list.d/ru-debian.list; \
    apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y nginx; \
    apt-get clean; \
    rm -rf /var/www/*; \
    mkdir -p /var/www/vatrubin.ru/img; \
    useradd --system --create-home --shell /usr/sbin/nologin "${SITE_USER}"; \
    groupadd "${SITE_GROUP}"; \
    usermod -aG "${SITE_GROUP}" "${SITE_USER}"

COPY index.html /var/www/vatrubin.ru/index.html
COPY img.png /var/www/vatrubin.ru/img/img.png

RUN chmod -R 754 /var/www/vatrubin.ru; \
    chown -R "${SITE_USER}:${SITE_GROUP}" /var/www/vatrubin.ru; \
    sed -i 's#/var/www/html#/var/www/vatrubin.ru#g' /etc/nginx/sites-enabled/default; \
    grep -R "^user " /etc/nginx; \
    sed -i "s/^user .*/user ${SITE_USER};/" /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
