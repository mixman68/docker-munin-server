FROM debian:buster

RUN apt-get update && apt-get install -y munin supervisor nginx spawn-fcgi logrotate curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown munin:munin /var/log/nginx/error.log \
    && chown munin:munin /var/log/nginx/access.log \
    && mkdir -p /var/run/munin \
    && chown munin:munin /var/run/munin \
    && mkdir -p /var/cache/munin/www \
    && chown munin:munin /var/cache/munin/www

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY munin.conf /etc/munin/munin.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

VOLUME /var/lib/munin
VOLUME /var/log/munin

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
HEALTHCHECK --interval=30s --timeout=30s --retries=3 CMD curl --fail http://localhost/munin/ || exit 1
