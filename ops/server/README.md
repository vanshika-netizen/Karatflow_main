# KaratFlow release puller

These files let the server pull the latest public GitHub Release over HTTPS.
They do not require GitHub Actions to SSH into the server.

## One-time server installation

An administrator should run:

```sh
install -m 0755 ops/server/karatflow-apk-update.sh /usr/local/bin/karatflow-apk-update
install -m 0644 ops/server/karatflow-apk-update.service /etc/systemd/system/karatflow-apk-update.service
install -m 0644 ops/server/karatflow-apk-update.timer /etc/systemd/system/karatflow-apk-update.timer
systemctl daemon-reload
systemctl enable --now karatflow-apk-update.timer
systemctl start karatflow-apk-update.service
```

The existing Nginx HTTPS server block must include the contents of
`nginx-downloads-location.conf`, then validate and reload Nginx:

```sh
nginx -t && systemctl reload nginx
```

The expected public URLs are:

- `https://YOUR_DOMAIN/downloads/`
- `https://YOUR_DOMAIN/downloads/latest.apk`
