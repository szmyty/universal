#!/usr/bin/env bash

set -euo pipefail

LABEL_NAME="app.name=universal"
LABEL_SCOPE="app.scope=universal.stack"

USE_LABELS=true
NUKE_ALL=false
DANGEROUS=false

filter_by_labels() {
    if [[ "$USE_LABELS" == true ]]; then
        docker "$@" --filter "label=${LABEL_NAME}" --filter "label=${LABEL_SCOPE}"
    else
        docker "$@"
    fi
}

stop_containers() {
    printf "⛔ Stopping containers...\n"
    filter_by_labels ps -aq | xargs -r docker stop
}

remove_containers() {
    printf "🗑️ Removing containers...\n"
    filter_by_labels ps -aq | xargs -r docker rm --force
}

remove_networks() {
    printf "🔌 Removing networks...\n"
    docker network ls --quiet | while read -r net_id; do
        if [[ "$USE_LABELS" == false ]] || docker network inspect "$net_id" | grep -q "$LABEL_NAME"; then
            docker network rm "$net_id" || true
        fi
    done
}

remove_images() {
    if [[ "$DANGEROUS" == true ]]; then
        printf "🧼 Removing Docker images...\n"
        docker images -aq | xargs -r docker rmi --force
    else
        printf "⚠️ Skipping image removal. Use --dangerous to remove images.\n"
    fi
}

remove_volumes() {
    printf "📦 Removing volumes...\n"
    docker volume ls --quiet | while read -r vol_id; do
        if [[ "$USE_LABELS" == false ]] || docker volume inspect "$vol_id" | grep -q "$LABEL_NAME"; then
            docker volume rm "$vol_id" || true
        fi
    done
}

clean_build_cache() {
    printf "🧹 Cleaning Docker build cache...\n"
    docker builder prune --all --force
}

system_prune() {
    if [[ "$DANGEROUS" == true ]]; then
        printf "💣 Performing system prune...\n"
        docker system prune --all --volumes --force
    fi
}

main() {
    stop_containers
    remove_containers
    remove_networks
    remove_volumes
    remove_images
    clean_build_cache
    system_prune
}

usage() {
    echo "Usage: $0 [--force] [--all] [--dangerous]"
    echo "  --force      Skip confirmation prompt"
    echo "  --all        Remove ALL Docker resources (ignores labels)"
    echo "  --dangerous  Also remove Docker images and run system prune"
    exit 1
}

main_wrapper() {
    local force=false

    for arg in "$@"; do
        case $arg in
            --force) force=true ;;
            --all) USE_LABELS=false; NUKE_ALL=true ;;
            --dangerous) DANGEROUS=true ;;
            -h|--help) usage ;;
            *) echo "Unknown argument: $arg" && usage ;;
        esac
    done

    if [[ "$force" == true ]]; then
        main
    else
        echo "⚠️  You are about to clean up Docker resources."
        [[ "$NUKE_ALL" == true ]] && echo "☢️  This will ignore labels and nuke everything."
        [[ "$DANGEROUS" == true ]] && echo "🔥 Images and build cache will also be deleted."
        read -rp "Are you sure? (y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] && main || { echo "❌ Cancelled."; exit 0; }
    fi
}

main_wrapper "$@"
