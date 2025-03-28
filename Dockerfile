FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl gnupg2 ca-certificates redis-server postgresql supervisor \
    python3 python3-pip python3-venv \
    libpq-dev build-essential git

# Add Authentik user and home
RUN useradd -m authentik

# Install Authentik
USER authentik
WORKDIR /home/authentik

RUN python3 -m venv venv
ENV PATH="/home/authentik/venv/bin:$PATH"

# Upgrade pip
RUN pip install --upgrade pip

# Clone Authentik source
RUN git clone https://github.com/goauthentik/authentik.git /home/authentik/authentik

# Install Authentik with Postgres support
WORKDIR /home/authentik/authentik
RUN pip install .[postgres]


# Setup folders
RUN mkdir -p /home/authentik/media /home/authentik/templates /home/authentik/certs

# Copy supervisord config
USER root
COPY supervisord.conf /etc/supervisor/conf.d/authentik.conf

EXPOSE 9000 9443
CMD ["/usr/bin/supervisord"]
