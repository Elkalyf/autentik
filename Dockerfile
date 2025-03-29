FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    redis-server postgresql supervisor \
    libpq-dev build-essential git \
    libffi-dev libssl-dev \
    libxml2-dev libxslt1-dev \
    libjpeg-dev zlib1g-dev \
    libkrb5-dev curl && \
    apt-get clean

# Add Authentik user
RUN useradd -m authentik

# Set working directory
WORKDIR /opt/authentik

# Clone and install Authentik
RUN git clone https://github.com/goauthentik/authentik.git . && \
    pip install --upgrade pip && \
    pip install ".[postgres]"

# Setup media folders
RUN mkdir -p /opt/authentik/media /opt/authentik/templates /opt/authentik/certs

# Copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/authentik.conf

EXPOSE 9000 9443

ENV PATH="/usr/local/bin:$PATH"


CMD ["/usr/bin/supervisord"]
