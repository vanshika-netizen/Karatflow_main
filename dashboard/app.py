import os
from time import monotonic

import requests
from flask import Flask, abort, flash, redirect, render_template, url_for
from werkzeug.middleware.proxy_fix import ProxyFix


REPOSITORY = os.environ.get("GITHUB_REPOSITORY", "vanshika-netizen/Karatflow_main")
WORKFLOW = os.environ.get("GITHUB_WORKFLOW_FILE", "android-server-build.yml")
GITHUB_API_URL = f"https://api.github.com/repos/{REPOSITORY}"
GITHUB_TOKEN = os.environ.get("GITHUB_BUILD_TOKEN")
SECRET_KEY = os.environ.get("DASHBOARD_SECRET_KEY")
BUILD_COOLDOWN_SECONDS = int(os.environ.get("BUILD_COOLDOWN_SECONDS", "300"))
last_dispatch_at = 0.0

if not all([GITHUB_TOKEN, SECRET_KEY]):
    raise RuntimeError("GITHUB_BUILD_TOKEN and DASHBOARD_SECRET_KEY are required.")

app = Flask(__name__)
app.secret_key = SECRET_KEY
app.wsgi_app = ProxyFix(app.wsgi_app, x_proto=1, x_host=1)


def github_request(method, path, **kwargs):
    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    response = requests.request(method, f"{GITHUB_API_URL}{path}", headers=headers, timeout=15, **kwargs)
    if not response.ok:
        app.logger.warning("GitHub request failed: %s %s", response.status_code, path)
        abort(502, "GitHub could not complete the build request.")
    return response


def build_context():
    runs = github_request("GET", f"/actions/workflows/{WORKFLOW}/runs?per_page=8").json().get("workflow_runs", [])
    latest_release = None
    release_response = requests.get(
        f"{GITHUB_API_URL}/releases/latest",
        headers={"Accept": "application/vnd.github+json", "Authorization": f"Bearer {GITHUB_TOKEN}"},
        timeout=15,
    )
    if release_response.ok:
        latest_release = release_response.json()
    return {"runs": runs, "latest_release": latest_release}


@app.get("/")
def dashboard():
    return render_template("dashboard.html", **build_context(), repository=REPOSITORY)


@app.post("/build")
def trigger_build():
    global last_dispatch_at
    elapsed = monotonic() - last_dispatch_at
    if elapsed < BUILD_COOLDOWN_SECONDS:
        remaining = int(BUILD_COOLDOWN_SECONDS - elapsed)
        flash(f"A build was requested recently. Try again in about {remaining} seconds.")
        return redirect(url_for("dashboard"))

    github_request("POST", f"/actions/workflows/{WORKFLOW}/dispatches", json={"ref": "main"})
    last_dispatch_at = monotonic()
    flash("Build requested. The status list will update after GitHub starts the run.")
    return redirect(url_for("dashboard"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
