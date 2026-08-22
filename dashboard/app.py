import os
import secrets
from functools import wraps

import requests
from flask import Flask, abort, flash, redirect, render_template, request, session, url_for
from werkzeug.middleware.proxy_fix import ProxyFix
from werkzeug.security import check_password_hash


REPOSITORY = os.environ.get("GITHUB_REPOSITORY", "vanshika-netizen/Karatflow_main")
WORKFLOW = os.environ.get("GITHUB_WORKFLOW_FILE", "android-server-build.yml")
GITHUB_API_URL = f"https://api.github.com/repos/{REPOSITORY}"
GITHUB_TOKEN = os.environ.get("GITHUB_BUILD_TOKEN")
PASSWORD_HASH = os.environ.get("DASHBOARD_PASSWORD_HASH")
SECRET_KEY = os.environ.get("DASHBOARD_SECRET_KEY")

if not all([GITHUB_TOKEN, PASSWORD_HASH, SECRET_KEY]):
    raise RuntimeError("GITHUB_BUILD_TOKEN, DASHBOARD_PASSWORD_HASH, and DASHBOARD_SECRET_KEY are required.")

app = Flask(__name__)
app.secret_key = SECRET_KEY
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
    SESSION_COOKIE_SECURE=os.environ.get("DASHBOARD_COOKIE_SECURE", "true").lower() == "true",
)
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


def require_login(view):
    @wraps(view)
    def wrapped(*args, **kwargs):
        if not session.get("authenticated"):
            return redirect(url_for("login"))
        return view(*args, **kwargs)
    return wrapped


def require_csrf():
    if request.form.get("csrf_token") != session.get("csrf_token"):
        abort(400, "Invalid form token.")


def build_context():
    runs = github_request("GET", f"/actions/workflows/{WORKFLOW}/runs?per_page=8").json().get("workflow_runs", [])
    try:
        latest_release = github_request("GET", "/releases/latest").json()
    except Exception:
        latest_release = None
    return {"runs": runs, "latest_release": latest_release}


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        if check_password_hash(PASSWORD_HASH, request.form.get("password", "")):
            session.clear()
            session["authenticated"] = True
            session["csrf_token"] = secrets.token_urlsafe(32)
            return redirect(url_for("dashboard"))
        flash("Incorrect password.")
    return render_template("login.html")


@app.post("/logout")
@require_login
def logout():
    require_csrf()
    session.clear()
    return redirect(url_for("login"))


@app.get("/")
@require_login
def dashboard():
    return render_template("dashboard.html", **build_context(), csrf_token=session["csrf_token"], repository=REPOSITORY)


@app.post("/build")
@require_login
def trigger_build():
    require_csrf()
    github_request("POST", f"/actions/workflows/{WORKFLOW}/dispatches", json={"ref": "main"})
    flash("Build requested. The status list will update after GitHub starts the run.")
    return redirect(url_for("dashboard"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
