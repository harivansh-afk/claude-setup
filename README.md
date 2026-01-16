# Claude Code VPS Setup

One-command setup for Claude Code with plugins, skills, and MCP servers.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/harivansh-afk/claude-setup/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/harivansh-afk/claude-setup.git
cd claude-setup
./install.sh
```

## What Gets Installed

### Plugins
- compound-engineering (every-marketplace)
- ralph-wiggum (autonomous coding loops)
- ralph-loop (background agent loops)
- code-simplifier (official Anthropic)

### Skills
- eval-skill (verifiable code generation with evals)
- Vercel agent-skills (React/Next.js best practices)
- rams (accessibility and design reviews)

### Tools
- agent-browser (browser automation CLI for agents)

### MCP Servers
- context7 (library documentation)
- exa (web search and code context)

## Post-Install

Add your API keys to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "context7": {
      "headers": {
        "CONTEXT7_API_KEY": "your-key-here"
      }
    },
    "exa": {
      "env": {
        "EXA_API_KEY": "your-key-here"
      }
    }
  }
}
```

## Usage

After install:

```bash
# Verify plugins
claude plugin list

# Start Claude
claude

# Use eval skill
/eval build <name>

# Use rams for design review
/rams
```
