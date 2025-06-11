FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    nginx curl libxml2-utils cron

COPY nginx.conf /etc/nginx/nginx.conf
COPY update_html.sh /usr/local/bin/update_html.sh
COPY mycron /etc/cron.d/mycron

RUN chmod +x /usr/local/bin/update_html.sh
RUN chmod 0644 /etc/cron.d/mycron && crontab /etc/cron.d/mycron
RUN mkdir -p /usr/share/nginx/html && touch /usr/share/nginx/html/index.html

CMD service cron start && nginx -g "daemon off;"
