# syntax=docker/dockerfile:1
FROM python:2.7.18-slim-buster as builder

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv"

COPY stack-requirements.txt stack-requirements.txt

RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    git \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    linux-headers-amd64 \
    python-psycopg2 \
    python2-dev \
    rsync \
    virtualenv 

RUN virtualenv -p /usr/bin/python2.7 $VIRTUAL_ENV
RUN $VIRTUAL_ENV/bin/pip install -r stack-requirements.txt 
# https://stackoverflow.com/a/10739838/9395299
RUN echo "/usr/local/lib/python2.7/lib-dynload" > $VIRTUAL_ENV/lib/python2.7/site-packages/path.pth 

FROM python:2.7.18-slim-buster

LABEL \
    maintainer="Mael Pedretti <mael.pedretti@vnv.ch>" \
    org.label-schema.name="Odoo Base (Buster-slim)"\
    org.label-schema.schema-version="1.0" \
    org.label-schema.version="1.0" 

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv" \
    PATH="$WORKDIR/venv/bin:$PATH" 

COPY --from=builder $WORKDIR $WORKDIR
COPY --from=builder /usr /usr

RUN adduser --disabled-password --gecos '' odoo \ 
    && mkdir -p /opt/odoo/current/ \
    && chown -R odoo:odoo /opt/odoo/ \
    && mkdir -p /var/log/gunicorn/ \
    && chown -R odoo:odoo /var/log/gunicorn/