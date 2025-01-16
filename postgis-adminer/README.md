Ref: https://hub.docker.com/_/postgres

```yml
# Use postgres/example user/password credentials

version: "3.9"

services:
  db:
    image: postgres
    restart: always
    # set shared memory limit when using docker-compose
    shm_size: 128mb
    # or set shared memory limit when deploy via swarm stack
    #volumes:
    #  - type: tmpfs
    #    target: /dev/shm
    #    tmpfs:
    #    size: 134217728
    #    128\*2^20 bytes = 128Mb
    environment:
      POSTGRES_PASSWORD: example

  adminer:
    image: adminer
    restart: always
    ports:
      - 8080:8080
```

Run `docker stack deploy -c stack.yml postgres` (or `docker-compose -f stack.yml up`), wait for it to initialize completely, and visit `http://swarm-ip:8080`, `http://localhost:8080`, or `http://host-ip:8080` (as appropriate).

## How to extend this image

There are many ways to extend the `postgres` image. Without trying to support every possible use case, here are just a few that we have found useful.

Environment Variables
The PostgreSQL image uses several environment variables which are easy to miss. The only variable required is `POSTGRES_PASSWORD`, the rest are optional.

Warning: the Docker specific variables will only have an effect if you start the container with a data directory that is empty; any pre-existing database will be left untouched on container startup.

`POSTGRES_PASSWORD`
This environment variable is required for you to use the PostgreSQL image. It must not be empty or undefined. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable.

Note 1: The PostgreSQL image sets up `trust` authentication locally so you may notice a password is not required when connecting from `localhost` (inside the same container). However, a password will be required if connecting from a different host/container.

Note 2: This variable defines the superuser password in the PostgreSQL instance, as set by the `initdb` script during initial container startup. It has no effect on the `PGPASSWORD` environment variable that may be used by the `psql` client at runtime, as described at https://www.postgresql.org/docs/14/libpq-envars.html⁠. `PGPASSWORD`, if used, will be specified as a separate environment variable.

`POSTGRES_USER`
This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of postgres will be used.

Be aware that if this parameter is specified, PostgreSQL will still show The files belonging to this database system will be owned by user "postgres" during initialization. This refers to the Linux system user (from /etc/passwd in the image) that the postgres daemon runs as, and as such is unrelated to the `POSTGRES_USER` option. See the section titled "Arbitrary --user Notes" for more details.

`POSTGRES_DB`
This optional environment variable can be used to define a different name for the default database that is created when the image is first started. If it is not specified, then the value of `POSTGRES_USER` will be used.

`POSTGRES_INITDB_ARGS`
This optional environment variable can be used to send arguments to `postgres initdb`. The value is a space separated string of arguments as `postgres initdb` would expect them. This is useful for adding functionality like data page checksums: `-e POSTGRES_INITDB_ARGS="--data-checksums"`.

`POSTGRES_INITDB_WALDIR`
This optional environment variable can be used to define another location for the Postgres transaction log. By default the transaction log is stored in a subdirectory of the main Postgres data folder (`PGDATA`). Sometimes it can be desireable to store the transaction log in a different directory which may be backed by storage with different performance or reliability characteristics.

Note: on PostgreSQL 9.x, this variable is `POSTGRES_INITDB_XLOGDIR` (reflecting the changed name of the `--xlogdir` flag to `--waldir` in PostgreSQL 10+⁠).

`POSTGRES_HOST_AUTH_METHOD`
This optional variable can be used to control the auth-method for host connections for all databases, all users, and all addresses. If unspecified then scram-sha-256 password authentication⁠ is used (in 14+; md5 in older releases). On an uninitialized database, this will populate pg_hba.conf via this approximate line:

`echo "host all all all $POSTGRES_HOST_AUTH_METHOD" >> pg_hba.conf`

See the PostgreSQL documentation on pg_hba.conf⁠ for more information about possible values and their meanings.

**Note 1**: It is not recommended to use trust since it allows anyone to connect without a password, even if one is set (like via `POSTGRES_PASSWORD`). For more information see the PostgreSQL documentation on Trust Authentication⁠.

**Note 2**: If you set `POSTGRES_HOST_AUTH_METHOD` to trust, then `POSTGRES_PASSWORD` is not required.

**Note 3**: If you set this to an alternative value (such as `scram-sha-256`), you might need additional `POSTGRES_INITDB_ARGS` for the database to initialize correctly (such as `POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256`).

`PGDATA`
Important Note: when mounting a volume to `/var/lib/postgresql`, the `/var/lib/postgresql/data` path is a local volume from the container runtime, thus data is not persisted on the mounted volume.

This optional variable can be used to define another location - like a subdirectory - for the database files. The default is `/var/lib/postgresql/data`. If the data volume you're using is a filesystem mountpoint (like with GCE persistent disks), or remote folder that cannot be chowned to the `postgres` user (like some NFS mounts), or contains folders/files (e.g. `lost+found`), Postgres `initdb` requires a subdirectory to be created within the mountpoint to contain the data.

For example:

```bash
$ docker run -d \
	--name some-postgres \
	-e POSTGRES_PASSWORD=mysecretpassword \
	-e PGDATA=/var/lib/postgresql/data/pgdata \
	-v /custom/mount:/var/lib/postgresql/data \
	postgres
```

This is an environment variable that is not Docker specific. Because the variable is used by the `postgres` server binary (see the PostgreSQL docs⁠), the entrypoint script takes it into account.
