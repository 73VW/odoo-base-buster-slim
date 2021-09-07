# odoo-base-buster-slim

Creates a base container for odoo 10 with a bunch of dependencies installed.

You can then reuse it with a custom Dockerfile.

## Example 

### Web service container

This assumes web container will run odoo behind gunicorn

#### structure

```bash
.
├── docker-compose.yml
└── odoo_web
    ├── Dockerfile
    ├── docker-entrypoint.sh
    ├── odoo-web-wsgi.py
    └── update.conf

```

#### docker-compose.yml

```yaml
version: "3.9"

services:
  odoo_db:
    container_name: odoo_db
    image: postgres:11
    volumes:
      - type: volume
        source: db_data
        target: /var/lib/postgresql/data
    environment: 
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"

  odoo_web:
    container_name: odoo_web
    build: 
      context: .
      dockerfile: PATH/TO/YOUR/DOCKERFILE
      args:
        WEB_PORT: ${WEB_PORT}
    ports:
      - "${WEB_PORT}:${WEB_PORT}"
    volumes:
      - type: bind
        source: /PATH/TO/YOUR/CODE/BASE
        target: /opt/odoo/current
      - type: bind
        source: ./odoo_web/odoo-web-wsgi.py
        target: /opt/odoo/odoo-web-wsgi.py
      - type: bind
        source: ~/eole-log
        target: /var/log/odoo/
      - type: volume
        source: filestore
        target: /opt/odoo/filestore
    depends_on:
      - odoo_db

networks:
  default:
    name: backend

volumes:
  filestore:
  db_data:
```

#### Dockerfile

```
# syntax=docker/dockerfile:1
FROM maelpedretti/odoo-base-buster-slim:packed

ARG WEB_PORT

WORKDIR $WORKDIR

USER odoo

COPY ./docker/odoo_web/odoo-web-wsgi.py ./odoo-web-wsgi.py
COPY ./docker/odoo_web/update.conf ./update.conf

EXPOSE $WEB_PORT
COPY ./docker/odoo_web/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
```
