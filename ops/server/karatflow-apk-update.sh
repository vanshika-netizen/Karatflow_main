#!/usr/bin/env bash
set -euo pipefail

release_base_url="https://github.com/vanshika-netizen/Karatflow_main/releases/latest/download"
download_dir="/var/www/app-downloads"

apk_tmp="$(mktemp "${download_dir}/.app-release.apk.XXXXXX")"
html_tmp="$(mktemp "${download_dir}/.index.html.XXXXXX")"
cleanup() {
  rm -f "${apk_tmp}" "${html_tmp}"
}
trap cleanup EXIT

curl --fail --location --silent --show-error --retry 3 \
  --output "${apk_tmp}" "${release_base_url}/app-release.apk"
test -s "${apk_tmp}"

curl --fail --location --silent --show-error --retry 3 \
  --output "${html_tmp}" "${release_base_url}/index.html"
test -s "${html_tmp}"

chmod 0644 "${apk_tmp}" "${html_tmp}"
mv -f "${apk_tmp}" "${download_dir}/latest.apk"
mv -f "${html_tmp}" "${download_dir}/index.html"
