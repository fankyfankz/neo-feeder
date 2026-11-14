# Neo Feeder

PDDikti Neo Feeder Docker menggunakan sistem terbaru (Debian 13 dan Node.js 26 LTS).

![visitors](https://visitor-badge.laobi.icu/badge?page_id=fankyfankz.neo-feeder&left_text=Viewed&radius=0)

## Daftar Isi

- [Prasyarat](#prasyarat)
- [Install Library Pendukung (zstd)](#install-library-pendukung-zstd)
- [Clone Repo](#clone-repo)
- [Menjalankan dengan Docker Compose](#menjalankan-dengan-docker-compose)
- [Menggunakan Image dari GHCR](#menggunakan-image-dari-ghcr)
- [Backup Database](#backup-database)
- [Restore Database](#restore-database)
- [Update Aplikasi](#update-aplikasi)
- [Troubleshooting](#troubleshooting)


## Prasyarat

Pastikan ini sudah terinstall di server:

- [Git](https://git-scm.com/)
- [Docker](https://docs.docker.com/engine/install/)
- [zstd](#install-library-pendukung-zstd)

Cek versi:

```bash
git --version
docker --version
docker compose version
zstd --version
```

## Install Library Pendukung (zstd)

`zstd` dipakai untuk mengompres dan mengekstrak file data/backup (`.zst`). Silahkan install terlebih dahulu.

**Debian / Ubuntu**

```bash
sudo apt update
sudo apt install -y zstd
```

**CentOS / RHEL / Rocky / AlmaLinux**

```bash
sudo dnf install -y zstd
```

**Alpine**

```bash
apk add --no-cache zstd
```

**macOS (Homebrew)**

```bash
brew install zstd
```

**Windows**

Via WSL2 (Ubuntu) lalu ikuti langkah Debian/Ubuntu di atas, atau install lewat `winget`:

```powershell
winget install Meta.Zstandard
```

Verifikasi:

```bash
zstd --version
```

## Clone Repo

```bash
git clone https://github.com/fankyfankz/neo-feeder.git
cd neo-feeder
```

Atau:

```bash
git clone --recurse-submodules https://github.com/fankyfankz/neo-feeder.git
```

## Menjalankan dengan Docker Compose

Build dan jalankan service di background:

```bash
docker compose up -d --build
```

Perintah yang sering dipakai:

| Info | Perintah |
|---|---|
| Lihat status container | `docker compose ps` |
| Lihat log semua service | `docker compose logs -f` |
| Lihat log satu service | `docker compose logs -f <nama-service>` |
| Restart | `docker compose restart` |
| Stop (data tetap ada) | `docker compose stop` |
| Hentikan dan hapus container | `docker compose down` |

Nama service bisa dicek dengan 
```bash
docker compose config --services
```

## Menggunakan Image dari GHCR
Pull Neo Feeder terupdate dari GHRC.

```bash
docker pull ghcr.io/fankyfankz/neo-feeder:latest
```

## Backup Database

**Note:**
Gunakan `db.sh` untuk backup maupun restore database (folder pgsql). Service otomatis akan dihentikan sementara secara otomatis ketika command dijalankan, tidak perlu menggunakan `docker compose stop`.

Tambah ijin eksekusi:

```bash
chmod +x ./db.sh
```

Secara default, folder backup akan dibuatkan otomatis active directory, jika ingin menempatkan backup di luar aplikasi,silahkan tentukan path. Contoh backup ke folder user:

```bash
./db.sh backup /home/fank
```

## Restore Database

Tentukan dimana lokasi file backup

   ```bash
   ./db.sh restore /home/fank/pgsql_XXXX.tar.zst
   ```

## Update Aplikasi

Github:

```bash
git pull
docker compose up -d --build
```

GHCR:

```bash
docker compose pull
docker compose up -d
```

Hapus image lama yang tidak terpakai:

```bash
docker image prune -f
```

**Selalu backup database sebelum update.**

## Troubleshooting

**`zstd: command not found`**
silahkan Install `zstd`, cek [Install Library Pendukung](#install-library-pendukung-zstd).

**`permission denied`** saat menjalankan docker,
Tambahkan user ke grup docker lalu login ulang:

```bash
sudo usermod -aG docker $USER
```

**Port alrady in use**
 brerarti ada proses yang memakai port, cek port yang ada di `docker-compose.yml` kemudian ubah:

```bash
sudo ss -tulpn | grep :<port>
```

**Container loop** silahkan cek log:

```bash
docker compose logs --tail=100 <nama-service>
```
