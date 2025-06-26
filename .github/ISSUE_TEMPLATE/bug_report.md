name: 🐞 Bug Report
description: Something is broken? Let us know!
title: "[Bug] "
labels: ["bug"]
assignees: []

body:

- type: markdown
  attributes:
  value: |
  Please provide as much context as possible. Screenshots or logs help a lot!
- type: input
  id: environment
  attributes:
  label: Environment
  description: OS, Node version, browser, platform, etc.
  placeholder: "e.g., macOS, Node 20.9, Firefox"
  validations:
  required: true
- type: textarea
  id: steps
  attributes:
  label: Steps to Reproduce
  description: Be as clear and concise as possible.
  placeholder: "1. Go to '...'\n2. Click on '...'\n3. See error"
  validations:
  required: true
- type: textarea
  id: expected
  attributes:
  label: Expected vs. Actual
  description: What you expected to happen vs. what actually happened.
- type: textarea
  id: logs
  attributes:
  label: Logs or Output
  render: shell
