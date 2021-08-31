# syntax=docker/dockerfile:1
FROM python:2.7.18-alpine

RUN pip install --upgrade pip

RUN apk update

RUN apk --no-cache add curl gcc python-dev linux-headers uwsgi-python musl-dev 
RUN apk --no-cache add g++ libxml2-dev libxslt-dev postgresql-libs 
RUN apk --no-cache add postgresql-dev gfortran openblas-dev lapack-dev jpeg-dev
RUN apk --no-cache add tiff-dev zlib-dev freetype-dev lcms2-dev libwebp-dev 
RUN apk --no-cache add tcl-dev tk-dev python2-tkinter

RUN adduser -D nonroot
RUN mkdir -p /opt/odoo/current/ && chown -R nonroot:nonroot /opt/odoo/
WORKDIR /opt/odoo/
USER nonroot

COPY stack-requirements.txt stack-requirements.txt

RUN pip install -r stack-requirements.txt