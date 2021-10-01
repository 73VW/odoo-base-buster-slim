# odoo-base-buster-slim

This is the base image you can use for your odoo 10 docker stack.

It is based on [python:2.7.18-slim-buster](https://hub.docker.com/layers/python/library/python/2.7.18-slim-buster/images/sha256-b956f27a04305bb15ae316a4af2421051105db86438e90fac01751ad11db4e85?context=explore)

## Features

A user `odoo` without password is created in order to run the app further.

This image contains `node`, `npm`, `wkhtmltopdf`, `python-lxml` and `python-psycopg2`.

The path where you will mount your code is in `/opt/odoo/current`.

The filestore path has to be set to `/opt/odoo/filestore`.

Venv path is `/opt/odoo/venv`

The folder `/opt/odoo` and all its children belong to `odoo` user and group.

Logs folder is supposed to be `/var/log/odoo/` and also belongs to `odoo`.

## Use it!

You can simply use it in your dockerfile in the `FROM` clause:

`FROM maelpedretti/odoo-base-buster-slim:packed`

