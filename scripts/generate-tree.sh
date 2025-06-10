#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: generate-tree.sh
#
# Description:
#   Generates a Markdown file (docs/tree.md) representing the Git-tracked
#   project directory structure, excluding the "reports" directory.
# ------------------------------------------------------------------------------

set -euo pipefail

generate_tree() {
    local output_path="docs/tree.md"

    echo "📁 Creating directory: docs/"
    mkdir -p docs

    echo "🛠️  Generating project tree into $output_path"
    {
        echo '# Project Structure'
        echo ''
        echo '```text'
        git ls-tree -r --name-only HEAD |
            grep -vE '^reports/' |
            tree --fromfile
        echo '```'
    } >"$output_path"

    echo "✅ Generated: $output_path"
    git add "$output_path"

    echo
    echo "📄 Preview:"
    head -n 10 "$output_path"
}

main() {
    echo "🚧 Starting generation of project structure tree..."
    generate_tree
    echo "🎉 Tree generation complete."
}

main "$@"
