#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# generate_password.sh
#
# Generate a secure password.
# ------------------------------------------------------------------------------
set -euo pipefail

# Generate a 32-character strong password (no weird shell chars)
generate_password() {
  openssl rand -base64 48 | tr -d '/+=' | cut -c1-32
}

# Main script execution
main() {
  if command -v openssl &> /dev/null; then
    password=$(generate_password)
    echo "Generated password: $password"
  else
    echo "Error: openssl command not found. Please install OpenSSL to generate a password."
    exit 1
  fi
}

# Run the main function
main "$@"
