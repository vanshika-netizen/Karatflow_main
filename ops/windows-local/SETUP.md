# Run KaratFlow as a local Windows build server

This setup runs the dashboard on your Windows computer and uses a GitHub
self-hosted runner on the same computer to build Android APKs.

The dashboard is local by default at `http://localhost:8080`. It is available
only while this computer and Docker Desktop are running.

## Prerequisites

Install and configure:

- Docker Desktop, with its engine running
- Git
- Java 17
- Flutter, including Android SDK and Android platform tools
- A GitHub self-hosted runner registered only to
  `vanshika-netizen/Karatflow_main`

Confirm Flutter can build before registering the runner:

```powershell
flutter doctor
flutter doctor --android-licenses
```

Create the APK output directory:

```powershell
New-Item -ItemType Directory -Force C:\Karatflow\app-downloads
```

## Register the Windows runner

In the GitHub repository go to:

`Settings → Actions → Runners → New self-hosted runner → Windows`

Run GitHub's generated download and configuration commands in PowerShell.
During configuration, assign the additional label:

```text
flutter-build
```

Run the runner as a Windows service. It must be online for automatic builds.

Never enable workflows from untrusted pull requests on this runner. This
repository is public; the workflow is intentionally restricted to `main`
pushes and manual dispatches.

## Configure the dashboard

Copy the example environment file:

```powershell
Copy-Item dashboard.env.example dashboard.env
```

Edit `dashboard.env` and set:

- `GITHUB_BUILD_TOKEN`: a fine-grained token limited to this repository,
  with Actions **Read and write** and Contents **Read**.
- `DASHBOARD_SECRET_KEY`: a long random value.
- `APK_DOWNLOAD_DIR`: keep `C:\Karatflow\app-downloads` unless you chose
  another directory.

Do not commit `dashboard.env`.

## Start the dashboard

From this directory:

```powershell
docker compose up -d --build
```

Open `http://localhost:8080`.

To access the dashboard from devices on the same Wi-Fi network, change:

```env
DASHBOARD_BIND_ADDRESS=0.0.0.0
```

Then restart the dashboard:

```powershell
docker compose up -d --build
```

Only expose this dashboard to the internet after adding HTTPS and additional
access protection. A public build button can otherwise be abused.

## Validate

1. Open the dashboard.
2. Select **Start Android build**.
3. Confirm the `Build Android APK locally` workflow starts.
4. Wait for it to succeed.
5. Download `latest.apk` from the dashboard.
6. Push a change to `main` and confirm it triggers the same workflow.
