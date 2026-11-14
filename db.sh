#!/usr/bin/env bash
set -euo pipefail
ORIG_PWD="$PWD"
cd "$(dirname "$0")"

KEEP="${KEEP:-14}"
SERVICE="db-pddikti"

abspath() { case "$1" in /*) echo "$1" ;; *) echo "$ORIG_PWD/$1" ;; esac; }

usage() {
  cat <<USAGE
Usage:
  $0 backup [dir]              # default: ./backups
  $0 restore /path/to/pgsql_XXXX.tar.zst
USAGE
  exit 1
}

backup() {
  local dir out
  dir="$(abspath "${1:-${BACKUP_DIR:-backups}}")"
  out="$dir/pgsql_$(date +%F_%H%M).tar.zst"
  mkdir -p "$dir"

  docker compose stop "$SERVICE"
  trap 'docker compose start '"$SERVICE" EXIT

  sudo tar --zstd -cpf "$out" -C ./pgsql data
  sudo chown "$(id -un):$(id -gn)" "$out"

  tar --zstd -tf "$out" > /dev/null
  echo "Backup OK: $out ($(du -h "$out" | cut -f1))"

  ls -1t "$dir"/pgsql_*.tar.zst | tail -n +$((KEEP + 1)) | xargs -r rm --
}

restore() {
  [ -n "${1:-}" ] || usage
  local archive; archive="$(abspath "$1")"
  [ -f "$archive" ] || { echo "Tidak ditemukan: $archive"; exit 1; }

  read -rp "Ini akan menimpa ./pgsql/data. Lanjutkan? [y/N] " ans
  [ "$ans" = "y" ] || exit 1

  docker compose stop "$SERVICE"
  [ -d pgsql/data ] && sudo mv pgsql/data "pgsql/data.old.$(date +%s)"

  sudo tar --zstd -xpf "$archive" -C ./pgsql --same-owner

  docker compose start "$SERVICE"
  echo "Data berhasil dipulihkan. Cek: docker compose logs $SERVICE"
}

case "${1:-}" in
  backup)  shift; backup "$@" ;;
  restore) shift; restore "$@" ;;
  *)       usage ;;
esac