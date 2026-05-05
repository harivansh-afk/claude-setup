# Claude Code VPS Setup

One-command setup for Claude Code with plugins, skills, and MCP servers.

## Quick Install

```bash
curl -fsSL https://git.harivan.sh/harivansh-afk/claude-setup/raw/branch/main/install.sh | bash
```

Or clone and run:

```bash
git clone https://git.harivan.sh/harivansh-afk/claude-setup.git
cd claude-setup
./install.sh
```

## What Gets Installed

### Plugins
| Plugin | Source | Description |
|--------|--------|-------------|
| compound-engineering | every-marketplace | 60+ agents, skills, and commands for development workflows |
| ralph-wiggum | claude-plugins-official | Autonomous coding loops |
| code-simplifier | claude-plugins-official | Code clarity and maintainability |

### Skills
| Skill | Source | Description |
|-------|--------|-------------|
| eval-skill | [harivansh-afk/eval-skill](https://git.harivan.sh/harivansh-afk/eval-skill) | Verifiable code generation with evals |
| vercel agent-skills | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | React/Next.js best practices |
| rams | [elirousso/rams](https://github.com/elirousso/rams) | Accessibility and design reviews |
| browser | [anthropics/claude-code](https://github.com/anthropics/claude-code) | Playwright browser automation |

### MCP Servers
| Server | Source | Description |
|--------|--------|-------------|
| context7 | [context7.com](https://context7.com) | Up-to-date library documentation |
| axiom | [axiomhq/mcp](https://github.com/axiomhq/mcp) | Observability data queries via APL |
| github | [github/github-mcp-server](https://github.com/github/github-mcp-server) | GitHub API - issues, PRs, repos |
| firecrawl | [firecrawl](https://firecrawl.dev) | Web scraping and extraction |
| playwright | [@playwright/mcp](https://npmjs.com/package/@anthropic-ai/playwright-mcp) | Browser automation for testing |

### Tools
| Tool | Source | Description |
|------|--------|-------------|
| agent-browser | npm | Browser automation CLI for agents |

## Post-Install

Add your API keys to `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "context7": {
      "headers": {
        "CONTEXT7_API_KEY": "your-key"
      }
    },
    "axiom": {
      "env": {
        "AXIOM_TOKEN": "xapt-your-token",
        "AXIOM_ORG_ID": "your-org-id"
      }
    },
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your-token"
      }
    },
    "firecrawl": {
      "env": {
        "FIRECRAWL_API_KEY": "your-key"
      }
    }
  }
}
```

## Usage

```bash
# Verify plugins
claude plugin list

# Start Claude
claude

# Use skills
/eval build <name>
/rams
/browser
```

## Manual Install (Individual Components)

### Plugins
```bash
claude plugin install compound-engineering --marketplace every-marketplace
claude plugin install ralph-wiggum
claude plugin install code-simplifier
```

### Skills
```bash
npx add-skill vercel-labs/agent-skills
npx add-skill elirousso/rams
```

### MCP Servers
See `~/.claude/mcp-servers.json` after running install.sh for full config.
