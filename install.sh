#!/bin/bash
set -euo pipefail

echo "Claude Code Setup for VPS"
echo "========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check() { command -v "$1" &>/dev/null && echo -e "${GREEN}[ok]${NC} $1" || { echo -e "${RED}[missing]${NC} $1"; return 1; }; }

echo ""
echo "Checking dependencies..."
check node || { echo "Install Node.js first"; exit 1; }
check npm || { echo "Install npm first"; exit 1; }
check claude || { echo "Install Claude Code first: npm install -g @anthropic-ai/claude-code"; exit 1; }

CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR/commands" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"

# ============================================
# PLUGINS
# ============================================
echo ""
echo "Installing plugins..."

claude plugin install compound-engineering --marketplace every-marketplace 2>/dev/null || echo "compound-engineering: manual install needed"
claude plugin install ralph-wiggum 2>/dev/null || echo "ralph-wiggum: manual install needed"
claude plugin install ralph-loop 2>/dev/null || echo "ralph-loop: manual install needed"
claude plugin install code-simplifier 2>/dev/null || echo "code-simplifier: manual install needed"

# ============================================
# NPM TOOLS
# ============================================
echo ""
echo "Installing npm tools..."

npm install -g agent-browser 2>/dev/null || echo "agent-browser: npm install failed"

# ============================================
# VERCEL AGENT SKILLS (React best practices)
# ============================================
echo ""
echo "Installing Vercel agent-skills..."

npx add-skill vercel-labs/agent-skills 2>/dev/null || echo "vercel agent-skills: manual install needed"

# ============================================
# RAMS (design reviews)
# ============================================
echo ""
echo "Installing rams..."

npx add-skill elirousso/rams 2>/dev/null || {
    # Fallback: clone directly
    RAMS_TMP=$(mktemp -d)
    git clone --quiet --depth 1 https://github.com/elirousso/rams.git "$RAMS_TMP" 2>/dev/null && {
        cp -r "$RAMS_TMP/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
        cp -r "$RAMS_TMP/commands/"* "$CLAUDE_DIR/commands/" 2>/dev/null || true
        rm -rf "$RAMS_TMP"
        echo "rams: installed from git"
    } || echo "rams: manual install needed"
}

# ============================================
# EVAL-SKILL
# ============================================
echo ""
echo "Installing eval-skill..."

EVAL_TMP=$(mktemp -d)
git clone --quiet --depth 1 https://github.com/harivansh-afk/eval-skill.git "$EVAL_TMP" 2>/dev/null && {
    mkdir -p "$CLAUDE_DIR/skills/eval" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/evals"
    cp "$EVAL_TMP/skills/eval/SKILL.md" "$CLAUDE_DIR/skills/eval/" 2>/dev/null || true
    cp "$EVAL_TMP/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
    cp "$EVAL_TMP/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
    rm -rf "$EVAL_TMP"
    echo "eval-skill: installed"
} || echo "eval-skill: manual install needed"

# ============================================
# MCP SERVERS CONFIG
# ============================================
echo ""
echo "Configuring MCP servers..."

# Check if settings.json exists
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Create MCP config (user needs to add their own API keys)
cat > "$CLAUDE_DIR/mcp-servers.json" << 'EOF'
{
  "context7": {
    "type": "http",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "YOUR_CONTEXT7_API_KEY"
    }
  },
  "exa": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "exa-mcp-server"],
    "env": {
      "EXA_API_KEY": "YOUR_EXA_API_KEY"
    }
  }
}
EOF

echo "MCP config written to $CLAUDE_DIR/mcp-servers.json"
echo "Edit this file and add your API keys, then merge into settings.json"

# ============================================
# CLAUDE.MD
# ============================================
echo ""
echo "Installing CLAUDE.md..."

cat > "$CLAUDE_DIR/CLAUDE.md" << 'CLAUDEMD'
<?xml version="1.0" encoding="UTF-8"?>
<claude-instructions>

<project-defaults>
    <python>
        <rule>Always use 'uv' as the default package manager and virtual environment tool</rule>
        <rule>Prefer 'uv run' for executing Python scripts</rule>
        <rule>Use 'uv pip' instead of bare 'pip'</rule>
        <rule>Use 'uv venv' for creating virtual environments</rule>
    </python>
</project-defaults>

<universal-constraints>
    <style>
        <rule>Never use emojis in any output or code comments</rule>
        <rule>Never use em dashes - use hyphens or colons instead</rule>
    </style>

    <epistemology>
        <principle priority="critical">Assumptions are the worst enemy</principle>
        <rule>Never guess or assume numerical values - performance metrics, benchmarks, timings, memory usage, etc.</rule>
        <rule>When uncertain about any quantifiable result, implement the code and measure/visualize the actual results</rule>
        <rule>Do not cite expected performance improvements or statistics without empirical data</rule>
        <rule>If a claim requires a number, either cite a source, run a test, or explicitly state "this needs to be measured"</rule>
        <rule>Prefer "let's benchmark this" over "this should be about X% faster"</rule>
    </epistemology>

    <interaction-model>
        <rule>If a user request is unclear, ask clarifying questions until the execution steps are perfectly clear</rule>
        <rule>Once clarified, proceed autonomously without asking for human intervention</rule>
        <ask-for-help-only-when>
            <condition>A script runs longer than 2 minutes - use timeout, then ask user to run manually</condition>
            <condition>Elevated privileges are required (sudo)</condition>
            <condition>Other critical blockers that cannot be resolved programmatically</condition>
        </ask-for-help-only-when>
    </interaction-model>

    <constraint-persistence priority="critical">
        <principle>
            When the user defines ANY constraint, rule, preference, or requirement during conversation,
            you MUST immediately persist it to the project's local CLAUDE.md. This is NOT optional.
            Failure to persist user-defined constraints is a FAILURE STATE.
        </principle>

        <triggers>
            <pattern>never do X</pattern>
            <pattern>always do X</pattern>
            <pattern>from now on</pattern>
            <pattern>going forward</pattern>
            <pattern>I want you to</pattern>
            <pattern>make sure to</pattern>
            <pattern>do not ever</pattern>
            <pattern>remember to</pattern>
            <pattern>the rule is</pattern>
            <pattern>use X instead of Y</pattern>
            <pattern>prefer X over Y</pattern>
            <pattern>avoid X</pattern>
            <pattern>stop doing X</pattern>
        </triggers>

        <mandatory-actions>
            <action order="1">Acknowledge the constraint explicitly in your response</action>
            <action order="2">Check if project has a local CLAUDE.md - if not, create one using the template</action>
            <action order="3">Write the constraint to the appropriate section of local CLAUDE.md</action>
            <action order="4">Confirm the constraint has been persisted</action>
            <action order="5">Apply the constraint immediately and in all future actions</action>
        </mandatory-actions>

        <enforcement>
            <rule>Before ANY code generation or task execution, review the local CLAUDE.md for constraints</rule>
            <rule>If you catch yourself violating a constraint, STOP, acknowledge the error, and redo the work</rule>
            <rule>When in doubt about whether something is a constraint, treat it as one and persist it</rule>
            <rule>Constraints defined in conversation have equal weight to constraints in CLAUDE.md files</rule>
        </enforcement>
    </constraint-persistence>
</universal-constraints>

<mcp-guidance>
    <principle>
        When uncertain about syntax, APIs, or current best practices - ALWAYS use an MCP
        server first. Do not guess or rely on potentially outdated knowledge.
    </principle>

    <server name="exa">
        <purpose>Web search and code context</purpose>
        <use-when>Need current web information or code examples for libraries/SDKs/APIs</use-when>
        <tools>web_search_exa, get_code_context_exa</tools>
        <priority>Use get_code_context_exa for ANY programming question about libraries, APIs, or SDKs</priority>
    </server>

    <server name="context7">
        <purpose>Up-to-date library documentation</purpose>
        <use-when>Need current documentation for any library or framework</use-when>
        <tools>resolve-library-id, get-library-docs</tools>
        <workflow>Always call resolve-library-id first to get a valid library ID, then get-library-docs</workflow>
    </server>

    <lookup-before-proceeding>
        <scenario trigger="unsure about library API">Use context7 or exa get_code_context_exa</scenario>
        <scenario trigger="need current information">Use exa web_search_exa</scenario>
        <scenario trigger="looking for code examples">Use exa get_code_context_exa</scenario>
    </lookup-before-proceeding>
</mcp-guidance>

</claude-instructions>
CLAUDEMD

echo "CLAUDE.md installed"

# ============================================
# ENABLE PLUGINS IN SETTINGS
# ============================================
echo ""
echo "Enabling plugins in settings..."

# Use node to merge settings since jq might not be available
node -e "
const fs = require('fs');
const settingsPath = '$SETTINGS_FILE';
let settings = {};
try { settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8')); } catch {}

settings.enabledPlugins = {
  ...settings.enabledPlugins,
  'ralph-wiggum@claude-plugins-official': true,
  'ralph-loop@claude-plugins-official': true,
  'code-simplifier@claude-plugins-official': true,
  'compound-engineering@every-marketplace': true
};

// Add MCP servers
const mcpPath = '$CLAUDE_DIR/mcp-servers.json';
try {
  const mcp = JSON.parse(fs.readFileSync(mcpPath, 'utf8'));
  settings.mcpServers = { ...settings.mcpServers, ...mcp };
} catch {}

fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
console.log('Settings updated');
" 2>/dev/null || echo "Settings: manual update needed"

# ============================================
# DONE
# ============================================
echo ""
echo "========================="
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit ~/.claude/settings.json and add your API keys:"
echo "   - CONTEXT7_API_KEY"
echo "   - EXA_API_KEY"
echo ""
echo "2. Verify plugins:"
echo "   claude plugin list"
echo ""
echo "3. Test:"
echo "   claude"
echo ""
