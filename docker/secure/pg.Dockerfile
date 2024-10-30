# This Dockerfile contains the image specification of our database
#? Refer to: https://dev.to/danvixent/how-to-setup-postgresql-with-ssl-inside-a-docker-container-5f3
FROM scratch as cert-inserter
WORKDIR /var/lib/postgresql
COPY ./certs/out/postgres.key /var/lib/postgresql
COPY ./certs/out/postgres.crt /var/lib/postgresql

COPY ./certs/out/ca.crt /var/lib/postgresql
# COPY ./certs/out/myCA.crl /var/lib/postgresql
WORKDIR /usr/local/bin
COPY ./ssl-conf.sh /usr/local/bin

FROM postgres:13-alpine as pg-alpine

COPY --from=cert-inserter /var/lib/postgresql /var/lib/postgresql
COPY --from=cert-inserter /usr/local/bin/ssl-conf.sh /usr/local/bin/ssl-conf.sh

#* 70:70 for alpine, 999:999 for debian
#? Alpine related
RUN chown 0:70 /var/lib/postgresql/postgres.key && chmod 640 /var/lib/postgresql/postgres.key
RUN chown 0:70 /var/lib/postgresql/postgres.crt && chmod 640 /var/lib/postgresql/postgres.crt
RUN chown 0:70 /var/lib/postgresql/ca.crt && chmod 640 /var/lib/postgresql/ca.crt
# RUN chown 0:70 /var/lib/postgresql/ca.crl && chmod 640 /var/lib/postgresql/ca.crl

ENTRYPOINT ["docker-entrypoint.sh"]

CMD [ "-c", "ssl=on" , "-c", "ssl_cert_file=/var/lib/postgresql/postgres.crt", "-c",\
  "ssl_key_file=/var/lib/postgresql/postgres.key", "-c",\
  "ssl_ca_file=/var/lib/postgresql/ca.crt" ]

#* Other useful links
#? https://www.crunchydata.com/blog/ssl-certificate-authentication-postgresql-docker-containers
#? https://medium.com/@e.saichik/intro-to-certificate-based-authentication-in-postgresql-231f717230a8
#? https://github.com/esaichik/Medium-PostgreSQL-Certificate-Authentication/tree/main

FROM postgres:13 as pg-debian

COPY --from=cert-inserter /var/lib/postgresql /var/lib/postgresql
COPY --from=cert-inserter /usr/local/bin/ssl-conf.sh /usr/local/bin/ssl-conf.sh

#? Debian Related images
RUN chown 0:999 /var/lib/postgresql/postgres.key && chmod 640 /var/lib/postgresql/postgres.key
RUN chown 0:999 /var/lib/postgresql/postgres.crt && chmod 640 /var/lib/postgresql/postgres.crt
RUN chown 0:999 /var/lib/postgresql/ca.crt && chmod 640 /var/lib/postgresql/ca.crt
# RUN chown 0:999 /var/lib/postgresql/ca.crl && chmod 640 /var/lib/postgresql/ca.crl

ENTRYPOINT ["docker-entrypoint.sh"]
#? add "-c", "ssl_crl_file=/var/lib/postgresql/myCA.crl" to the command below
CMD [ "-c", "ssl=on" , "-c", "ssl_cert_file=/var/lib/postgresql/postgres.crt", "-c",\
  "ssl_key_file=/var/lib/postgresql/postgres.key", "-c",\
  "ssl_ca_file=/var/lib/postgresql/ca.crt"]
