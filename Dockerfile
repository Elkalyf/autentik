FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl gnupg2 ca-certificates \
    redis-server postgresql supervisor \
    python3 python3-pip python3-venv \
    libpq-dev build-essential git \
    libffi-dev libssl-dev \
    libxml2-dev libxslt1-dev \
    libjpeg-dev zlib1g-dev \
    gcc make


# Create Authentik user and venv
RUN useradd -m authentik
USER authentik
WORKDIR /home/authentik
RUN python3 -m venv venv
ENV PATH="/home/authentik/venv/bin:$PATH"



# Install pip and Authentik
RUN pip install --upgrade pip
RUN git clone https://github.com/goauthentik/authentik.git /home/authentik/authentik
WORKDIR /home/authentik/authentik
RUN pip install .[postgres]


# Setup folders
RUN mkdir -p /home/authentik/media /home/authentik/templates /home/authentik/certs

# Copy supervisord config
USER root
COPY supervisord.conf /etc/supervisor/conf.d/authentik.conf

EXPOSE 9000 9443
CMD ["/usr/bin/supervisord"]
