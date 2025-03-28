FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    redis-server postgresql supervisor \
    libpq-dev build-essential git \
    libffi-dev libssl-dev \
    libxml2-dev libxslt1-dev \
    libjpeg-dev zlib1g-dev \
    libkrb5-dev curl

# Add Authentik user
RUN useradd -m authentik
USER authentik
WORKDIR /home/authentik

# Clone and install Authentik
RUN git clone https://github.com/goauthentik/authentik.git /home/authentik/authentik
WORKDIR /home/authentik/authentik
RUN pip install --upgrade pip && pip install .[postgres]

# Back to home directory
WORKDIR /home/authentik

# Setup folders
RUN mkdir -p /home/authentik/media /home/authentik/templates /home/authentik/certs

# Copy supervisord config
USER root
COPY supervisord.conf /etc/supervisor/conf.d/authentik.conf

EXPOSE 9000 9443
RUN echo "🔍 Searching for authentik binary..." && find / -type f -name authentik 2>/dev/null

CMD ["/usr/bin/supervisord"]
