# syntax=docker/dockerfile:1
FROM python:2.7.18-buster as builder

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv"

RUN apt-get update 
RUN apt-get install -y build-essential
RUN apt-get install -y gcc
RUN apt-get install -y git 
RUN apt-get install -y libevent-dev 
RUN apt-get install -y libkeyutils-dev 
RUN apt-get install -y libldap2-dev 
RUN apt-get install -y libpq-dev 
RUN apt-get install -y libsasl2-dev 
RUN apt-get install -y libssl-dev 
RUN apt-get install -y libxml2-dev 
RUN apt-get install -y libxslt-dev 
RUN apt-get install -y linux-headers-amd64 
RUN apt-get install -y python-lxml
RUN apt-get install -y python-pip 
RUN apt-get install -y python-psycopg2 
RUN apt-get install -y python2-dev 
RUN apt-get install -y virtualenv 
RUN apt-get install -y wget
RUN git clone https://github.com/odoo/odoo.git --branch=10.0 --depth=1


RUN virtualenv -p /usr/bin/python2.7 $VIRTUAL_ENV
COPY stack-requirements.txt stack-requirements.txt
RUN $VIRTUAL_ENV/bin/pip install -r stack-requirements.txt
COPY odoo-requirements.txt odoo-requirements.txt
RUN $VIRTUAL_ENV/bin/pip install -r odoo-requirements.txt
RUN $VIRTUAL_ENV/bin/pip install ./odoo

# https://stackoverflow.com/a/10739838/9395299
RUN echo "/usr/local/lib/python2.7/lib-dynload" > $VIRTUAL_ENV/lib/python2.7/site-packages/path.pth 

RUN adduser --disabled-password --gecos '' odoo  
RUN mkdir -p /opt/odoo/current/ 
RUN mkdir -p /opt/odoo/filestore

RUN wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb --directory-prefix /opt/odoo/

FROM python:2.7.18-slim-buster as image

ARG BUILD_DATE
ARG VCS_REF

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv" \
    PATH="$WORKDIR/venv/bin:$PATH" 

RUN adduser --disabled-password --gecos '' odoo

COPY --chown=odoo:odoo --from=builder $WORKDIR $WORKDIR 

RUN apt-get update && apt-get install -y --no-install-recommends \
    /opt/odoo/wkhtmltox_0.12.6-1.buster_amd64.deb \
    node-less \
    python-lxml \
    python-psycopg2 \
    net-tools \
    wget \
    && rm /opt/odoo/wkhtmltox_0.12.6-1.buster_amd64.deb \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/odoo/ && chown -R odoo:odoo /var/log/odoo/ \
    && mkdir -p /var/odoo/ && chown -R odoo:odoo /var/odoo/

WORKDIR $WORKDIR

USER odoo

LABEL maintainer="VNV SA <web@vnv.ch>" \
    python.version="2.7.18" \
    os.architecture="amd64" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.schema-version="1.0" \
    org.label-schema.url="https://git.vnv.ch/vnv/containers/odoo" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.vcs-url="https://git.vnv.ch/vnv/containers/odoo" \
    org.opencontainers.image.authors="Maël Pedretti <mael.pedretti@vnv.ch>" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.description="Odoo container for local development" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://git.vnv.ch/vnv/containers/odoo" \
    org.opencontainers.image.title="Odoo" \
    org.opencontainers.image.url="https://git.vnv.ch/vnv/containers/odoo" \
    org.opencontainers.image.vendor="VNV SA <web@vnv.ch>"

FROM image as debug

RUN pip install debugpy

ENV GEVENT_SUPPORT=True

FROM image as profile

RUN pip install blackfire