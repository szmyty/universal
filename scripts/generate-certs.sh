#!/usr/bin/env bash
set -euo pipefail

CERTS_DIR="./certs"
KEY_FILE="${CERTS_DIR}/cert.key"
CRT_FILE="${CERTS_DIR}/cert.crt"
DAYS_VALID=825
SUBJECT="/C=US/ST=Local/L=Localhost/O=Dev/CN=localhost"

create_certs_dir() {
  if [[ ! -d "${CERTS_DIR}" ]]; then
    printf "🔧 Creating certs directory at %s...\n" "${CERTS_DIR}"
    mkdir -p "${CERTS_DIR}"
  fi
}

generate_self_signed_cert() {
  printf "🔐 Generating self-signed SSL certificate for localhost...\n"
  openssl req \
    -x509 \
    -nodes \
    -newkey rsa:2048 \
    -keyout "${KEY_FILE}" \
    -out "${CRT_FILE}" \
    -days "${DAYS_VALID}" \
    -subj "${SUBJECT}" \
    -addext "basicConstraints=CA:FALSE"

  printf "✅ Certificate generated:\n"
  printf "   🔑 Key : %s\n" "${KEY_FILE}"
  printf "   📄 Cert: %s\n" "${CRT_FILE}"
}

verify_openssl() {
  if ! command -v openssl &> /dev/null; then
    printf "❌ 'openssl' is required but not installed. Aborting.\n" >&2
    exit 1
  fi
}

main() {
  verify_openssl
  create_certs_dir
  generate_self_signed_cert
}

main "$@"
