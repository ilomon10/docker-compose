
# RUN

Specify the Group ID and User ID to handle volume permission, see the `uid` and `gid` by run this command:

```bash
$ id user
uid=1000(user) gid=1000(user) ...
```

then input the `uid` and `gid`

```bash
$ GID=1000 UID=1000 docker compose up
```
