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
# Build image locally (or pull from ghcr)
cd /path/to/roxabi-xcli
podman build -t ghcr.io/roxabi/clix:latest .

# Copy Quadlet unit
mkdir -p ~/.config/containers/systemd
cp deploy/quadlet/clix.container ~/.config/containers/systemd/

# Create data dir
mkdir -p ~/.roxabi/clix/config

# Reload + start
systemctl --user daemon-reload
systemctl --user start clix
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
