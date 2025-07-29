#!/usr/bin/env bash
set -euo pipefail

# ─── CONFIG ─────────────────────────────────────────────────────────────
OUTPUT_DIR=".git-activity-summary"
SINCE="${1:-3 months ago}"
GOURCE_IMAGE="${OUTPUT_DIR}/gource.png"
ASCII_LOG="${OUTPUT_DIR}/log-graph.txt"
STATS_FILE="${OUTPUT_DIR}/commit-stat-summary.txt"
SHORTLOG_FILE="${OUTPUT_DIR}/shortlog-summary.txt"
INSPECTOR_DIR="${OUTPUT_DIR}/gitinspector-report"

# ─── UTILITIES ──────────────────────────────────────────────────────────
log() {
  echo -e "\033[1;34m[INFO]\033[0m $*"
}

ensure_output_dir() {
  mkdir -p "$OUTPUT_DIR"
}

require_tool() {
  command -v "$1" >/dev/null || {
    echo >&2 "[ERR] Required tool '$1' not found. Please install it."; exit 1;
  }
}

# ─── EXPORT ASCII GIT LOG ───────────────────────────────────────────────
export_ascii_log() {
  log "Generating ASCII commit graph..."
  git log --all --since="$SINCE" --graph --decorate --oneline > "$ASCII_LOG"
  log "Saved: $ASCII_LOG"
}

# ─── EXPORT COMMIT STATS (insertions/deletions) ─────────────────────────
export_commit_stats() {
  log "Generating commit stat summary..."
  git log --all --since="$SINCE" --author="$(git config user.name)" --shortstat > "$STATS_FILE"
  log "Saved: $STATS_FILE"
}

# ─── EXPORT AUTHOR SUMMARY ──────────────────────────────────────────────
export_shortlog() {
  log "Generating author contribution summary..."
  git shortlog -sne --all --since="$SINCE" > "$SHORTLOG_FILE"
  log "Saved: $SHORTLOG_FILE"
}

# ─── EXPORT GOURCE SNAPSHOT ─────────────────────────────────────────────
export_gource_image() {
  require_tool gource
  require_tool ffmpeg

  log "Generating Gource image snapshot..."
  gource --seconds-per-day 0.25 --start-date "$SINCE" \
    --title "Git Activity" \
    --highlight-users \
    --user-scale 2 \
    --multi-sampling \
    --stop-at-end \
    --hide filenames,dirnames,mouse \
    --output-ppm-stream - | \
    ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vframes 1 "$GOURCE_IMAGE"

  log "Saved: $GOURCE_IMAGE"
}

# ─── EXPORT GITINSPECTOR HTML REPORT ────────────────────────────────────
export_gitinspector_report() {
  require_tool gitinspector

  log "Generating GitInspector report..."
  mkdir -p "$INSPECTOR_DIR"
  gitinspector -f html --since="$SINCE" . > "${INSPECTOR_DIR}/index.html"
  log "Saved: ${INSPECTOR_DIR}/index.html"
}

# ─── MAIN ───────────────────────────────────────────────────────────────
main() {
  ensure_output_dir
  export_ascii_log
  export_commit_stats
  export_shortlog
  export_gource_image
  export_gitinspector_report

  log "✅ All Git summaries saved to: $OUTPUT_DIR"
}

main "$@"
