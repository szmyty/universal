# Keycloak Service

This directory stores configuration for the Keycloak container used in development.

The `development-realm.json` file contains a preconfigured realm with sample users and roles. When the development Docker Compose stack is started, this realm is imported automatically.

Production and demo environments require a manually configured realm; no import occurs.
