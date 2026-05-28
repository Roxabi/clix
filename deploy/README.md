# XCLI Deployment — Quadlet (Podman + systemd)

Containerized Clix (Twitter/X CLI) on M1 (`roxabituwer`) via Podman Quadlet.

## Stack

| Service | Image | Purpose |
|---------|-------|---------|
| clix | `ghcr.io/roxabi/clix:latest` | Twitter/X CLI tool |

## Data dirs

```
~/.roxabi/clix/
└── config/
    └── auth.json   # persisted cookies / credentials
```

## Install

```bash
# Pull image from GHCR (auto-published by CI — see "Image lifecycle" below)
podman pull ghcr.io/roxabi/clix:latest

# Copy Quadlet unit
mkdir -p ~/.config/containers/systemd
cp deploy/quadlet/clix.container ~/.config/containers/systemd/

# Create data dir
mkdir -p ~/.roxabi/clix/config

# Reload + start
systemctl --user daemon-reload
systemctl --user start clix
```

### Local build (fallback)

Use when iterating on the Dockerfile before the workflow has run:

```bash
cd /path/to/roxabi-xcli
podman build -t ghcr.io/roxabi/clix:latest .
```

## Image lifecycle

Workflow: `.github/workflows/publish.yml` — image: `ghcr.io/roxabi/clix`

| Trigger | Tags produced |
|---------|--------------|
| Push to `main` | `:latest` |
| Push of `v*` tag | `:<version>` + `:<major>` (e.g. `v1.2.3` → `:1.2.3` + `:1`) |

OCI labels applied: `source` (repo URL), `revision` (git SHA), `version` (ref name). These
override the upstream `astral-sh/uv` labels inherited from `FROM`, which previously made
staleness detection misleading.

Watch a run: `gh run watch -R Roxabi/roxabi-xcli`

## Update running image on M₁

```bash
ssh roxabituwer "podman pull ghcr.io/roxabi/clix:latest && systemctl --user restart clix.service"
```

Verify revision label matches expected commit SHA:

```bash
podman image inspect ghcr.io/roxabi/clix:latest --format '{{index .Labels "org.opencontainers.image.revision"}}'
```

## Authenticate

Browser cookie extraction does not work inside the container. Use manual auth:

```bash
# Extract cookies from your local browser, then:
ssh roxabituwer "podman exec clix clix auth set --token <auth_token> --ct0 <ct0>"
```

Or set via env before exec:
```bash
ssh roxabituwer "podman exec -e X_AUTH_TOKEN=xxx -e X_CT0=yyy clix clix auth status --json"
```

## Usage

```bash
# From any tailnet machine
ssh roxabituwer "podman exec clix clix post 'Hello world'"
ssh roxabituwer "podman exec clix clix feed --count 10 --json"
ssh roxabituwer "podman exec clix clix search 'query' --json"
```

## Auto-start

Enabled via `[Install] WantedBy=default.target` in `clix.container` + `loginctl enable-linger $USER`.
