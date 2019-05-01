FROM nginx

RUN rm /etc/nginx/conf.d/default.conf

RUN mkdir -p /var/www/Aspire-F5-571.private.over-a-barrel.co.uk
RUN mkdir -p /var/www/Aspire-F5-571.private.over-a-barrel.co.uk/cache

RUN mkdir -p /root/certs/Aspire-F5-571.private.over-a-barrel.co.uk

COPY certs /root/certs/Aspire-F5-571.private.over-a-barrel.co.uk
RUN chmod 400 /root/certs/Aspire-F5-571.private.over-a-barrel.co.uk/Aspire-F5-571.private.over-a-barrel.co.uk.key

COPY conf /etc/nginx
COPY conf/html/* /var/www/Aspire-F5-571.private.over-a-barrel.co.uk/

EXPOSE 443



