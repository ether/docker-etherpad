# [docker-etherpad](https://github.com/ether/docker-etherpad)

LinuxServer.io-style Docker image for [Etherpad](https://etherpad.org), a real-time collaborative document editor.

This repository follows the LinuxServer.io conventions (Alpine baseimage, s6-overlay v3, `abc` user, `/config` volume). It is maintained by the Etherpad Foundation in collaboration with the LSIO team and is intended to be adopted into the `linuxserver/` org once it stabilises.

## Quick start

```bash
docker run -d \
  --name=etherpad \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 9001:9001 \
  -v /path/to/etherpad/config:/config \
  --restart unless-stopped \
  ghcr.io/ether/etherpad-lsio:latest
```

Then open `http://<your-host>:9001/`.

## Persistence

Everything that survives a container recreate lives under `/config`:

| Path | Purpose |
|---|---|
| `/config/settings.json` | Etherpad configuration (seeded on first run from `settings.json.docker`). |
| `/config/etherpad.db` | sqlite pad store (default; switch via `dbType` in settings.json). |
| `/config/var/` | `installed_plugins.json`, sessionkey, APIKEY (symlinked to `/app/etherpad-lite/var` inside the container). |
| `/config/plugins.txt` | Optional list of plugins (one name per line) installed automatically on boot. |

The container switches the upstream template's `dirty` (dev-only) DB to sqlite on first boot, pointing the file at `/config/etherpad.db`. To use Postgres or MySQL instead, edit `/config/settings.json` after first launch.

## Versions

| Tag | Description |
|---|---|
| `latest` | Latest stable Etherpad release. |
| `v3.0.0`, `v2.7.3`, ... | Specific Etherpad versions. |

## License

Apache-2.0 (same as upstream Etherpad).
