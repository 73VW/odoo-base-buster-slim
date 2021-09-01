# syntax=docker/dockerfile:1
FROM python:2.7.18-slim-buster as Builder

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv"

COPY stack-requirements.txt stack-requirements.txt
COPY odoo-requirements.txt odoo-requirements.txt

RUN apt-get update && apt-get install -y \
    gcc \
    git \
    libkeyutils-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    linux-headers-amd64 \
    python-psycopg2 \
    python2-dev \
    virtualenv \
    wget

RUN virtualenv -p /usr/bin/python2.7 $VIRTUAL_ENV
RUN $VIRTUAL_ENV/bin/pip install -r stack-requirements.txt 
RUN $VIRTUAL_ENV/bin/pip install -r odoo-requirements.txt 
RUN git clone https://github.com/odoo/odoo.git --branch=10.0 --depth=1
RUN cd odoo && $VIRTUAL_ENV/bin/pip install .

# https://stackoverflow.com/a/10739838/9395299
RUN echo "/usr/local/lib/python2.7/lib-dynload" > $VIRTUAL_ENV/lib/python2.7/site-packages/path.pth 

RUN adduser --disabled-password --gecos '' odoo  
RUN mkdir -p /opt/odoo/current/ 
RUN mkdir -p /opt/odoo/filestore
RUN chown -R odoo:odoo /opt/odoo/

FROM python:2.7.18-slim-buster as Image

LABEL \
    maintainer="Mael Pedretti <mael.pedretti@vnv.ch>" \
    org.label-schema.name="Odoo Base (Buster-slim)"\
    org.label-schema.schema-version="1.0" \
    org.label-schema.version="1.0" 

ENV WORKDIR="/opt/odoo"
ENV VIRTUAL_ENV="$WORKDIR/venv" \
    PATH="$WORKDIR/venv/bin:$PATH" 

RUN adduser --disabled-password --gecos '' odoo \
    && apt-get update && apt-get install -y --no-install-recommends\
    git \
    node-less \
    python-psycopg2 \
    wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/odoo/ && chown -R odoo:odoo /var/log/odoo/

COPY --from=Builder $WORKDIR $WORKDIR