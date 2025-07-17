✅ Mount VS Code Logs into DevContainer for Debugging
Description
Allow DevContainer scripts and tools to inspect VS Code logs by mounting the host-side log directory.

Proposed Change

Add the following to devcontainer.json:

Linux:

json
Copy
Edit
"mounts": [
  "source=${env:HOME}/.config/Code/logs,target=/vscode-logs,type=bind,consistency=cached"
]
macOS:

json
Copy
Edit
"source=${env:HOME}/Library/Application Support/Code/logs,target=/vscode-logs,type=bind"
Benefits

Allows real-time access to extension host, container lifecycle, and remote logs

Enables debugging tools/scripts inside the container

Can support tail -f /vscode-logs/*/*/*.log or a helper script

Next Steps

Optional: add tail-vscode-logs.sh helper script

Optional: include in Taskfile.yml as debug:logs
