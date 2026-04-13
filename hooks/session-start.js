#!/usr/bin/env node
// Runs on SessionStart. Checks if agents are installed in the current project.
const fs = require('fs');
const path = require('path');

const cwd = process.cwd();
const agentsPath = path.join(cwd, '.claude', 'agents', 'CLAUDE.md');

if (!fs.existsSync(agentsPath)) {
  const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT || path.join(__dirname, '..');
  process.stdout.write(
    `SDLC: agents not installed in this project.\n` +
    `Run: bash "${pluginRoot}/hooks/install.sh" to set up roles and pipeline files.\n`
  );
}
