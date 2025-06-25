FROM httpd@sha256:f6557a77ee2f16c50a5ccbb2564a3fd56087da311bf69a160d43f73b23d3af2d

# Install Apache modules
RUN apt-get update && \
    apt-get install --yes curl libapache2-mod-auth-openidc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
