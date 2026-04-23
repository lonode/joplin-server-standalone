# joplin-server-standalone

Joplin Server with bundled database (PostgreSQL)

Joplin Server container image with bundled PostgreSQL, specifically made for Nextcloud All-In-One community-containers mechanism. 

**Not recommended for any other deployment**, you should rather deploy 
PostgreSQL as a separate container using their official image, as per the official [joplin server documentation](https://hub.docker.com/r/joplin/server).

# Deployment

- Default port 22300
- Default user/pwd : admin@localhost / admin
- PostgreSQL is hosted on its default port 5432 but not exposed externally (bound to localhost). There is no reason to expose this port to the host.
  - Default database : joplin
  - Postgres creds : joplin/joplin

`docker run -p 22300:22300 ghcr.io/lonode/joplin-server-standalone:latest`

