FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /app

# Install deps for curl_cffi / browser_cookie3
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY pyproject.toml uv.lock README.md ./
COPY clix ./clix

# Install project
RUN uv sync --frozen --no-dev

# Ensure config dir exists for volume mount
RUN mkdir -p /root/.config/clix

ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["clix"]
