# Self-hosted Nunux Keeper

> Your personal content curation service.

This project is an automated setup to configure and run a self-hosted instance
of Nunux Keeper.

## Prerequisites

* [Docker][docker]
* [Docker Compose][docker-compose]
* [Make][make]
* At least 2GB of free Memory
* A bit of patience depending of your bandwidth

## Installation

The installation is fully automated. Simply run the following commands on a
Docker host:

```bash
git clone https://github.com/nunux-keeper/keeper-docker.git
cd keeper-docker
make deploy
```

This command will setup the following services:

- [Traefik][traefik]: A dynamic reverse proxy used to route incoming requests to
  appropriate backend.
- [MongoDB][mongodb]: The database backend.
- [Elasticsearch][elasticsearch]: The search engine backend.
- [Redis][redis]: The in-memory database used as an event bus by the job
  scheduler.
- [Keycloak][keycloak]: The Identity and Access Management service. This service
  is auto configured by scripting.
- [Nunux Keeper Core API][nunux-keeper-core-api]: The core API of Nunux Keeper.
- [Nunux Keeper job worker][nunux-keeper-job-worker]: A job worker for Nunux
  Keeper background tasks.
- [Nunux Keeper Web App][nunux-keeper-web-app]: The Web App of Nunux Keeper.

Container's persistent data are located into the `./var` directory. If you want
to make a fresh installation from scratch don't forget to destroy this
directory.

## Uninstallation

Uninstallation is as simple:

```bash
make undeploy
```

## Configuration

Configuration is located into the `./etc` directory. Please check `*.env` files
in order to see what parameters can you change to fit your needs.
Beware that some parameters can break this automatic setup and should not be
modified.

By default the application is configured to be hosted on http://localhost. If
you want to change this you can edit the `.env` file.

## Usage

Once started, Yous can access to those URL:

- http://localhost/auth : Identity And Access Management service
  (Username/Password: admin/admin)
- http://localhost/keeper : Nunux Keeper Web App (Username/Password:
  keeper/keeper)
- http://localhost/api : Nunux Keeper API
- http://localhost:8080 : Traefik dashboard

## What is missing?

There is some missing parts not very useful for doing content curation. But you
may be interested in:

- [Nunux Keeper Portal][nunux-keeper-web-portal]: The official Nunux Keeper web
  portal.
- [Nunux Keeper CLI][nunux-keeper-cli]: The CLI
- Metrics production: Nunux Keeper is able to produce metrics to any
  [StatsD][statsd] collector. Then you can aggregate and visualize those metrics
  with some great tools like [InfluxDB][influxdb] and [Grafana][grafana].
- Object Storage: Nunux Keeper is able to use a [S3][s3] compatible object
  storage (like [Minio][minio]) to store documents attachments.
- And a lot of operational stuff: monitoring, alerting, backups, etc.

## Troubleshooting

If you have trouble to start Elasticsearch and you have the following message
into your logs:

```
make logs service=elasticsearch

...
max virtual memory areas vm.max_map_count [65530] is too low, increase to atleast [262144]
...
```

You have to increase this system property and restart some services:

```
sudo sysctl -w vm.max_map_count=262144
make restart service=elasticsearch
make restart service=keeper-core-api
make restart service=keeper-job-worker
```

[docker]: https://docs.docker.com/engine/installation/
[docker-compose]: https://docs.docker.com/compose/install/
[make]: https://www.gnu.org/software/make/

[traefik]: https://traefik.io/
[keycloak]: http://www.keycloak.org
[mongodb]: https://www.mongodb.com
[elasticsearch]: https://www.elastic.co
[redis]: http://redis.io/
[statsd]: https://github.com/b/statsd_spec
[s3]: https://aws.amazon.com/s3
[minio]: https://www.minio.io/
[influxdb]: https://www.influxdata.com/
[grafana]: https://grafana.net/

[nunux-keeper-core-api]: https://github.com/nunux-keeper/keeper-core-api
[nunux-keeper-job-worker]: https://github.com/nunux-keeper/keeper-core-api/tree/master/src/job
[nunux-keeper-web-app]: https://github.com/nunux-keeper/keeper-web-app
[nunux-keeper-web-portal]: https://github.com/nunux-keeper/nunux-keeper.github.io
[nunux-keeper-cli]: https://github.com/nunux-keeper/keeper-cli

----------------------------------------------------------------------

NUNUX Keeper

Copyright (c) 2016 Nicolas CARLIER (https://github.com/ncarlier)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

----------------------------------------------------------------------
