# This Dockerfile contains the image specification of our database
#? Refer to: https://dev.to/danvixent/how-to-setup-postgresql-with-ssl-inside-a-docker-container-5f3
FROM scratch AS cert-inserter

WORKDIR /var/lib/postgresql/certs
COPY docker/ssl/postgres/ca.crt .
# COPY docker/ssl/postgres/ca.crl /var/lib/postgresql/certs

WORKDIR /var/lib/postgresql/certs/server
#* server
COPY docker/ssl/postgres/server/ .

#* client
WORKDIR /var/lib/postgresql/certs/client
COPY docker/ssl/postgres/client/ .
# COPY docker/ssl/postgres/server/postgres.key /var/lib/postgresql/certs/server
# COPY docker/ssl/postgres/server/postgres.crt /var/lib/postgresql/certs/server
# client
# COPY docker/ssl/postgres/client/postgres.key /var/lib/postgresql/certs/client
# COPY docker/ssl/postgres/client/postgres.crt /var/lib/postgresql/certs/client



#? Hostbased Auth config
# COPY docker/config/postgres/pg_hba.conf /var/lib/postgresql
# COPY docker/config/postgres/postgresql.conf /var/lib/postgresql
#? echo ssl setting into pg_hba.conf configuration file
# WORKDIR /usr/local/bin
# COPY ./ssl-conf.sh /usr/local/bin

# WORKDIR /var/lib/postgresql/data
#? Hostbased Auth config
# COPY docker/config/postgres/pg_hba.conf /var/lib/postgresql/data
# COPY docker/config/postgres/postgresql.conf /var/lib/postgresql/data

# COPY docker/ssl/postgres/server/postgres.key /var/lib/postgresql/data
# COPY docker/ssl/postgres/server/postgres.crt /var/lib/postgresql/data
# COPY docker/ssl/postgres/ca.crt /var/lib/postgresql/data

FROM postgres:13-alpine AS pg-alpine

#* 70:70 for alpine, 999:999 for debian
#* postgres:postgres for alpine, postgres:postgres for debian
#* 640 when using 0:70 | 0:999 || 600 when using 70:70 | 999:999
#? Alpine related
COPY --from=cert-inserter --chown=0:70 /var/lib/postgresql/certs/* /var/lib/postgresql/certs
RUN chmod 640 /var/lib/postgresql/certs/server/postgres.key
RUN chmod 640 /var/lib/postgresql/certs/server/postgres.crt
RUN chmod 640 /var/lib/postgresql/certs/client/postgres.key
RUN chmod 640 /var/lib/postgresql/certs/client/postgres.crt
RUN chmod 640 /var/lib/postgresql/certs/ca.crt
# RUN chown 0:70 /var/lib/postgresql/data/postgres.crt && chmod 640 /var/lib/postgresql/data/postgres.crt
# RUN chown 0:70 /var/lib/postgresql/data/ca.crt && chmod 640 /var/lib/postgresql/data/ca.crt
# RUN chown 0:70 /var/lib/postgresql/ca.crl && chmod 640 /var/lib/postgresql/ca.crl


#* Other useful links
#? https://www.crunchydata.com/blog/ssl-certificate-authentication-postgresql-docker-containers
#? https://medium.com/@e.saichik/intro-to-certificate-based-authentication-in-postgresql-231f717230a8
#? https://github.com/esaichik/Medium-PostgreSQL-Certificate-Authentication/tree/main

FROM postgres:13 AS pg-debian

COPY --from=cert-inserter /var/lib/postgresql/data /var/lib/postgresql/data
# COPY --from=cert-inserter /usr/local/bin/ssl-conf.sh /usr/local/bin/ssl-conf.sh

#? Debian Related images
# TODO: alter the permissions of the files
RUN chown 0:999 /var/lib/postgresql/data/postgres.key && chmod 640 /var/lib/postgresql/data/postgres.key
RUN chown 0:999 /var/lib/postgresql/data/postgres.crt && chmod 640 /var/lib/postgresql/data/postgres.crt
RUN chown 0:999 /var/lib/postgresql/data/ca.crt && chmod 640 /var/lib/postgresql/data/ca.crt
# RUN chown 0:999 /var/lib/postgresql/data/ca.crl && chmod 640 /var/lib/postgresql/data/ca.crl

FROM tensorchord/pgvecto-rs:pg14-v0.2.0 AS pgvector
# NOOPT=true
# EXPOSE 5432

# FROM pgvector as pgvector-pw

# #? add "-c", "ssl_crl_file=/var/lib/postgresql/myCA.crl" to the command below
# ENTRYPOINT ["docker-entrypoint.sh"]

# CMD [ "postgres", \
#   "-c", "shared_preload_libraries=vectors.so" \
#   '-c', 'search_path="$$user", public, vectors' \
#   '-c', 'logging_collector=on' \
#   '-c' 'max_wal_size=2GB' \
#   '-c' 'shared_buffers=512MB' \
#   '-c' 'wal_compression=on' \
#   ]

# COPY --from=cert-inserter /var/lib/postgresql/ /var/lib/postgresql

#? Debian Related images
COPY --from=cert-inserter /var/lib/postgresql/ /var/lib/postgresql

RUN chown 0:999 /var/lib/postgresql/certs/server/postgres.key && chmod 640 /var/lib/postgresql/certs/server/postgres.key
RUN chown 0:999 /var/lib/postgresql/certs/server/postgres.crt && chmod 640 /var/lib/postgresql/certs/server/postgres.crt
RUN chown 0:999 /var/lib/postgresql/certs/server/postgres.crt && chmod 640 /var/lib/postgresql/certs/client/postgres.key
RUN chown 0:999 /var/lib/postgresql/certs/client/postgres.crt && chmod 640 /var/lib/postgresql/certs/client/postgres.crt
RUN chown 0:999 /var/lib/postgresql/certs/ca.crt && chmod 640 /var/lib/postgresql/certs/ca.crt

# RUN chown 0:999 /var/lib/postgresql/postgres.key && chmod 640 /var/lib/postgresql/postgres.key
# RUN chown 0:999 /var/lib/postgresql/postgres.crt && chmod 640 /var/lib/postgresql/postgres.crt
# RUN chown 0:999 /var/lib/postgresql/ca.crt && chmod 640 /var/lib/postgresql/ca.crt

# ENTRYPOINT ["docker-entrypoint.sh"]

# #? add "-c", "ssl_crl_file=/var/lib/postgresql/myCA.crl" to the command below
# CMD [ 'postgres', "-c", "shared_preload_libraries=vectors.so", "-c", 'search_path="$$user", public, vectors',"-c","logging_collector=on","-c","max_wal_size=2GB","-c","shared_buffers=512MB","-c","wal_compression=on","-c", "hba_file=/var/lib/postgresql/pg_hba.conf","-c", "ssl=on","-c", "ssl_cert_file=/var/lib/postgresql/postgres.crt","-c", "ssl_key_file=/var/lib/postgresql/postgres.key","-c", "ssl_ca_file=/var/lib/postgresql/ca.crt" ]

