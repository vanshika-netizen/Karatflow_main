# KaratFlow server build dashboard

This installs a public dashboard and a dedicated GitHub Actions runner on the
server. Anyone can view build status, download the latest APK, and request a
build of the current `main` branch.

## Security model

- The dashboard does not expose a GitHub token. The token stays only in
  `/etc/karatflow-dashboard/dashboard.env`.
- Public build requests are limited to one every five minutes. The dashboard
  always dispatches `main`; it cannot build arbitrary branches or commands.
- Keep the repository private if possible. It is currently public, so never run
  pull-request workflows on this runner.
- Run the GitHub runner as `buildrunner`, not root, and do not grant it sudo.
- Expose the dashboard only through an HTTPS Nginx site.

## Server prerequisites

An administrator installs Docker, Java 17, Flutter, Android SDK command-line
tools, Git, curl, and the GitHub Actions runner. Allocate at least 4 CPU cores,
8 GB RAM, and 30 GB free disk for reliable Android builds.

Create the service account and APK directory:

```sh
useradd --create-home --shell /bin/bash buildrunner
install --directory --owner=buildrunner --group=buildrunner --mode=0755 /var/www/app-downloads
install --directory --owner=root --group=root --mode=0700 /etc/karatflow-dashboard
```

Register the GitHub Actions runner as `buildrunner`, restricted to this
repository and labelled `flutter-build`. Follow GitHub's generated registration
command; the registration token is short-lived and must not be committed.

## Dashboard secrets

Create `/etc/karatflow-dashboard/dashboard.env` with permissions `0600`:

```env
GITHUB_REPOSITORY=vanshika-netizen/Karatflow_main
GITHUB_WORKFLOW_FILE=android-server-build.yml
GITHUB_BUILD_TOKEN=replace-with-a-fine-grained-token
DASHBOARD_SECRET_KEY=replace-with-a-random-32-byte-secret
BUILD_COOLDOWN_SECONDS=300
```

The fine-grained GitHub token must be limited to this repository and granted:
- Actions: Read and write
- Contents: Read

Generate the session secret on the server:

```sh
openssl rand -hex 32
```

Do not put the token or secret in the repository.

## Dashboard deployment

Copy the repository to the server, then:

```sh
docker compose -f ops/server/dashboard-compose.yml up -d --build
```

Add `nginx-dashboard.conf` inside the existing HTTPS Nginx server block,
validate, and reload:

```sh
nginx -t && systemctl reload nginx
```

The dashboard is at the HTTPS root. Its direct APK link is:

```text
https://YOUR_DOMAIN/downloads/latest.apk
```

## Validation

1. Open the dashboard.
2. Select **Start Android build**.
3. Confirm GitHub Actions starts `android-server-build.yml`.
4. Wait for build success.
5. Confirm `/var/www/app-downloads/latest.apk` changes.
6. Download the APK from the dashboard.
7. Push an approved change to `main` and confirm the same workflow runs.
