FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Copy project files
COPY pyproject.toml uv.lock ./
COPY prepare.py train.py program.md ./

# Install dependencies
RUN uv sync --no-dev

# Create data and output directories
RUN mkdir -p data output

# Expose no ports (CLI-only application)
# HEALTHCHECK not applicable (runs training jobs)

# Default command (override with actual training)
CMD ["uv", "run", "train.py"]
